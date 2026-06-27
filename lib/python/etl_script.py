import os
import requests
import pandas as pd
import joblib
from sqlalchemy import create_engine, text
from datetime import datetime, timedelta

# GitHub Actions wird diese Werte später sicher in das Skript injizieren
NASA_API_KEY = os.getenv("NASA_API_KEY")
NEON_DB_URL = os.getenv("NEON_DB_URL")

# Engine erstellen
engine = create_engine(NEON_DB_URL)

if not NASA_API_KEY or not NEON_DB_URL:
    raise ValueError("Umgebungsvariablen nicht gefunden!")

def extract_nasa_data():
    today = datetime.now().strftime("%Y-%m-%d")
    # Asteroiden, die heute bis in eine Woche der Erde nahe kommen
    end_date = (datetime.now() + timedelta(days=7)).strftime("%Y-%m-%d")
    
    url = f"https://api.nasa.gov/neo/rest/v1/feed?start_date={today}&end_date={end_date}&api_key={NASA_API_KEY}"
    response = requests.get(url)
    
    if response.status_code == 200:
        print("✅ Extract erfolgreich!")
        return response.json()['near_earth_objects']
    else:
        raise Exception(f"Fehler bei der NASA API: {response.status_code}")
    

def transform_data(raw_data):
    asteroids_list = []
    
    # raw_data ist ein Dictionary mit Daten als Keys
    for date, asteroids in raw_data.items():
        for ast in asteroids:
            # Nur die Daten extrahieren, die wir für die Datenbank brauchen
            asteroid_dict = {
                'id': ast['id'],
                'name': ast['name'],
                'estimated_diameter_min_km': ast['estimated_diameter']['kilometers']['estimated_diameter_min'],
                'estimated_diameter_max_km': ast['estimated_diameter']['kilometers']['estimated_diameter_max'],
                'relative_velocity_kph': float(ast['close_approach_data'][0]['relative_velocity']['kilometers_per_hour']),
                'miss_distance_km': float(ast['close_approach_data'][0]['miss_distance']['kilometers']),
                'is_potentially_hazardous': ast['is_potentially_hazardous_asteroid'],
                'close_approach_date': ast['close_approach_data'][0]['close_approach_date'],
            }
            asteroids_list.append(asteroid_dict)
            
    df = pd.DataFrame(asteroids_list)

    try:

        # Den absoluten Pfad zur .joblib Datei dynamisch ermitteln
        script_dir = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.join(script_dir, 'asteroid_danger_model.joblib')

        model = joblib.load(model_path)

        features = [
            'estimated_diameter_min_km', 
            'estimated_diameter_max_km', 
            'relative_velocity_kph', 
            'miss_distance_km'
        ]

        X = df[features]

        y_pred = model.predict(X)

        df['model_prediction'] = y_pred
        print("Vorhersage hinzugefügt.")
    except Exception as e:
        print(f"Fehler beim Modell: {e}")
        df['model_prediction'] = None

    print(f"{len(df)} Asteroiden verarbeitet.")
    return df

def load_and_cleanup(df, engine):
    
    with engine.connect() as conn:
        # NEU 1: Wir zwingen Python dazu, die IDs als reinen Text (String) zu behandeln
        df['id'] = df['id'].astype(str)
        
        # NEU 2: Falls die NASA denselben Asteroiden für diese Woche 2x gemeldet hat, behalten wir nur den ersten
        df = df.drop_duplicates(subset=['id'])
        
        # Trick: Hole alle IDs, die schon in der Datenbank existieren
        existing_ids_df = pd.read_sql("SELECT id FROM asteroids", conn)
        
        # NEU 3: Auch die IDs aus der Datenbank zur Sicherheit in Strings umwandeln
        existing_ids = existing_ids_df['id'].astype(str).tolist()
        
        # Filtere das DataFrame: Behalte nur Asteroiden, deren ID NICHT in der DB ist
        df_new = df[~df['id'].isin(existing_ids)]
        
        if not df_new.empty:
            # Neue Asteroiden hochladen
            df_new.to_sql('asteroids', con=conn, if_exists='append', index=False)
            print(f"✅ Load erfolgreich! {len(df_new)} neue Asteroiden hochgeladen.")
        else:
            print("✅ Load übersprungen. Keine neuen Asteroiden gefunden (Alle schon in der DB).")
        
        # Cleanup: Alles löschen, was älter als 60 Tage ist, um Platz zu sparen
        cleanup_query = text("DELETE FROM asteroids WHERE close_approach_date < CURRENT_DATE - INTERVAL '60 days'")
        conn.execute(cleanup_query)
        conn.commit()
        print("✅ Cleanup erfolgreich! Alte Daten wurden aufgeräumt.")

def export_to_json(engine):
    print("🚀 Starte Export der JSON-Datei für das Frontend...")
    # Wir holen uns die 20 Asteroiden, die uns als nächstes am nächsten kommen
    query = """
    SELECT * FROM asteroids 
    WHERE close_approach_date >= CURRENT_DATE 
    ORDER BY close_approach_date ASC 
    LIMIT 20
    """
    df_export = pd.read_sql(query, engine)
    
    # Als JSON speichern
    df_export.to_json('data.json', orient='records', date_format='iso', indent=4)
    print("✅ data.json wurde erfolgreich im Hauptordner erstellt.")

# Die eigentliche Pipeline-Ausführung
try:
    raw_json = extract_nasa_data()
    clean_dataframe = transform_data(raw_json)
    load_and_cleanup(clean_dataframe, engine)
    export_to_json(engine)
    print("ETL-Pipeline durchgelaufen!")
except Exception as e:
    print(f"Ein Fehler ist aufgetreten: {e}")