import 'package:flutter/material.dart';

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
  // Map<String,dynamic> = JSON-Daten
  //late Future<Map<String, dynamic>> _asteroid_data;

  // initState wird einmalig beim Start des Widgets aufgerufen
  @override
  void initState() {
    super.initState();
    // Hier dann laden der Asteroiden-Daten
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold = Grundstruktur der Seite
      appBar: AppBar( 
        backgroundColor: Colors.grey,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Asteroiden-Tracker',
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        actions: [        
          IconButton(
            onPressed: widget.onToggleTheme, 
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode)),
        ],
      ),
    );
  }
}