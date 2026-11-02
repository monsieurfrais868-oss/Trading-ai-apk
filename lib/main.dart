import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const TradingAIApp());
}

class TradingAIApp extends StatelessWidget {
  const TradingAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading AI Analysis',
      theme: ThemeData.dark(),
      home: const AnalysisScreen(),
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  File? _imageM30;
  File? _imageM5;
  bool _isLoading = false;
  String _resultText = "Veuillez uploader les graphiques M30 et M5.";

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isM30) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isM30) {
          _imageM30 = File(pickedFile.path);
        } else {
          _imageM5 = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _analyzeCharts() async {
    if (_imageM30 == null || _imageM5 == null) {
      setState(() {
        _resultText = "Erreur : Il faut les deux captures (M30 et M5) !";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = "Analyse SMC, FVG et Price Action en cours...";
    });

    // TODO: Ici tu intègreras ton appel HTTP vers l'API de l'IA 
    // en envoyant les images encodées avec le prompt système.
    await Future.delayed(const Duration(seconds: 3)); // Simulation

    setState(() {
      _isLoading = false;
      _resultText = "BUY : 76%\n\n"
          "• M30 : Rupture de structure haussière et comblement de FVG.\n"
          "• M5 : Confirmation par MSS (Market Structure Shift) et test d'un Order Block.\n"
          "• Justification : Les acheteurs prennent le contrôle sur l'imbalance.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IA Trading Assistant (M30 + M5)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(true),
              icon: const Icon(Icons.image),
              label: Text(_imageM30 == null ? '1. Charger le graphique M30' : 'M30 Chargé ✓'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(false),
              icon: const Icon(Icons.image),
              label: Text(_imageM5 == null ? '2. Charger le graphique M5' : 'M5 Chargé ✓'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _isLoading ? null : _analyzeCharts,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Lancer l\'analyse globale'),
            ),
            const SizedBox(height: 30),
            const Text('Résultat de l\'IA :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_resultText, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
