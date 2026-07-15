import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class HomePage extends StatefulWidget {

  // Callback = Funktion, die später aufgerufen wird.
  // Funktion ohne Parameter und Rückgabewert. Wird für
  // Darkmode/Lightmode verwendet
  final VoidCallback onToggleTheme;
  final bool isDark;

  // Konstruktor, welcher die Funktion onToogleTheme und den
  // Bool-Wert für das Thema enthält
  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  // Future = Ergebnis ist noch nicht vorhanden, wird aber in der Zukunft gelifert. 
  late Future<List<dynamic>> _asteroidData;

  // initState wird einmalig beim Start des Widgets aufgerufen
  @override
  void initState() {
    super.initState();
    _asteroidData = fetchAsteroids();
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/KonstantinKoenigshofen/asteroid_classifier');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<List<dynamic>> fetchAsteroids() async {
    const url = 'https://raw.githubusercontent.com/KonstantinKoenigshofen/asteroid_classifier/refs/heads/main/data.json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Fehler beim Laden: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold( // Scaffold = Grundstruktur der Seite
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'ASTEROIDEN-TRACKER',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _asteroidData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Asteroiden-Daten gefunden.'));
          }

          final asteroids = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    // Nutzt das neongrüne Akzent-Schema mit sehr hoher Transparenz
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Über dieses Projekt",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          children: [
                            const TextSpan(
                              text: "Diese Seite zeigt die 20 nächsten Himmelskörper, die in den kommenden Tagen an der Erde vorbeifliegen. "
                                  "Die Daten stammen dabei von der NASA-API \"Asteroids - NeoWs\", von der am Anfang jeder Woche neue Asteroiden geladen werden. "
                                  "Neben der Einschätzung der NASA über die Gefährlichkeit des Asteroiden ist die Vorhersage eines Random-Forest-Modells zu sehen, welches mithilfe der Daten aus der API trainiert wurde.\n\n"
                                  "Für weitere Informationen und den Programmcode: ",
                            ),
                            TextSpan(
                              text: "github.com/KonstantinKoenigshofen/asteroid_classifier",
                              style: TextStyle(
                                color: theme.colorScheme.primary, 
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = _launchUrl, 
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Die nächsten 20 nahen Vorbeiflüge:",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Expanded sorgt dafür, dass die Liste den restlichen Platz einnimmt
                Expanded(
                  child: ListView.builder(
                    itemCount: asteroids.length,
                    itemBuilder: (context, index) {
                      final ast = asteroids[index];
                      final isHazardousNasa = ast['is_potentially_hazardous'] == true;
                      final isHazardousModel = ast['model_prediction'] == true;

                      // Wir bauen ein schickes Karten-Layout statt einer breiten Tabelle
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Zeile 1: Name & ID
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ast['name'] ?? 'Unbekannt',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${ast['id']}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              
                              // Zeile 2: Details als vertikale Paare (Schlüssel-Wert)
                              _buildDetailRow(
                                'Datum:', 
                                (ast['close_approach_date'] as String).substring(0, 10),
                              ),
                              _buildDetailRow(
                                'Größe (Min/Max):', 
                                '${(ast['estimated_diameter_min_km'] as double).toStringAsFixed(3)} - ${(ast['estimated_diameter_max_km'] as double).toStringAsFixed(3)} km',
                              ),
                              _buildDetailRow(
                                'Geschwindigkeit:', 
                                '${(ast['relative_velocity_kph'] as double).round()} km/h',
                              ),
                              _buildDetailRow(
                                'Entfernung (Miss Distance):', 
                                '${(ast['miss_distance_km'] as double).round()} km',
                              ),
                              const SizedBox(height: 12),
                              
                              // Zeile 3: Die Einstufungen (NASA vs. ML-Modell)
                              Row(
                                children: [
                                  _buildStatusBadge('NASA', isHazardousNasa),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge('KI-Modell', isHazardousModel),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hilfswidget für die Schlüssel-Wert-Zeilen
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }

  // Hilfswidget für die Gefahren-Badges
  Widget _buildStatusBadge(String source, bool isHazardous) {
    final color = isHazardous ? Colors.redAccent : const Color(0xFF28965A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHazardous ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
            size: 14, 
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$source: ${isHazardous ? "GEFÄHRLICH" : "SICHER"}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}