import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String _resultText = "Veuillez uploader les graphiques M30 et M5 pour lancer l'analyse SMC.";

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
        _resultText = "Erreur : Il faut impérativement les deux captures (M30 et M5) !";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = "Analyse institutionnelle en cours (SMC, FVG, M30 & M5)...";
    });

    try {
      // Remplace par ta clé API Gemini ou ton endpoint
      const apiKey = "AQ.Ab8RN6JKeXwSHpGwo8m1dif66PMzoQnQZE7q-MmHUEjPXcyl0Q"; 
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

      // Conversion des images en Base64
      final bytesM30 = await _imageM30!.readAsBytes();
      final base64M30 = base64Encode(bytesM30);

      final bytesM5 = await _imageM5!.readAsBytes();
      final base64M5 = base64Encode(bytesM5);

      final promptText = "Agis en tant qu'expert trader en SMC, Price Action, FVG et Imbalances. "
          "L'image 1 est le M30 (structure globale, tendance, zones institutionnelles). "
          "L'image 2 est le M5 (confirmations d'entrée, MSS, timing). "
          "Analyse les deux graphiques combinés. Donne un pourcentage net et précis de BUY ou de SELL, "
          "suivi de l'analyse détaillée du M30, du M5 et de la justification technique.";

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": promptText},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64M30
                }
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64M5
                }
              }
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _resultText = aiResponse;
        });
      } else {
        setState(() {
          _resultText = "Erreur API : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultText = "Erreur technique : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                : const Text('Lancer l\'analyse globale par l\'IA'),
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
