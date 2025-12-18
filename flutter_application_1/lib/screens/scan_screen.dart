import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice_scanner/models/invoice_models.dart';
import 'package:invoice_scanner/utils/invoice_parser.dart';
import 'package:invoice_scanner/screens/verification_screen.dart';
import 'package:image_picker/image_picker.dart';  // Para ImageSource (ya estaba)

class ScanScreen extends StatefulWidget {
  final ImageSource source;
  const ScanScreen({super.key, required this.source});  // AGREGADO: const aquí

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isLoading = false;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();

  Future<void> _processImage() async {
    setState(() => _isLoading = true);

    try {
      final XFile? image = await _picker.pickImage(source: widget.source);
      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final textoCrudo = recognizedText.text;

      // Parsing asíncrono (rápido, pero simula async)
      final invoice = await Future.microtask(() => InvoiceParser.parse(textoCrudo));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(invoice: invoice),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en OCR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Captura ${widget.source == ImageSource.camera ? 'Cámara' : 'Galería'}')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Estado de carga para evitar ANR
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.source == ImageSource.camera ? Icons.camera : Icons.photo,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _processImage,
                    child: Text('Iniciar ${widget.source == ImageSource.camera ? 'Captura' : 'Selección'}'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
      ),
    );
  }
}