import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:invoice_scanner/models/invoice_models.dart';
import 'package:invoice_scanner/utils/invoice_parser.dart';
import 'package:invoice_scanner/screens/verification_screen.dart';

class LiveScanScreen extends StatefulWidget {
  const LiveScanScreen({super.key});  // AGREGADO: const

  @override
  State<LiveScanScreen> createState() => _LiveScanScreenState();
}

class _LiveScanScreenState extends State<LiveScanScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  Timer? _timer;
  final TextRecognizer _textRecognizer = TextRecognizer();
  Invoice? _currentInvoice;  // Datos en tiempo real
  String _ocrText = 'Enfoca la factura...';  // Texto crudo para debug

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});

    // Inicia OCR en vivo cada 500ms
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _processLiveFrame());
  }

  Future<void> _processLiveFrame() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final textoCrudo = recognizedText.text;
      setState(() => _ocrText = textoCrudo);

      final invoice = InvoiceParser.parse(textoCrudo);
      if (mounted) setState(() => _currentInvoice = invoice);
    } catch (e) {
      // Ignora errores en frames
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _captureAndVerify() {
    if (_currentInvoice != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerificationScreen(invoice: _currentInvoice!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear en Vivo')),
      body: Stack(
        children: [
          // Preview de cámara
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          // Overlay con datos detectados (en tiempo real)
          if (_currentInvoice != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha: ${_currentInvoice!.fechaEmision ?? "No detectada"}', style: const TextStyle(color: Colors.white)),
                    Text('Total: \$${_currentInvoice!.montoTotal?.toStringAsFixed(2) ?? "No detectado"}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    if (_currentInvoice!.codigoFactura != null)
                      Text('Código: ${_currentInvoice!.codigoFactura}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          // Debug: Texto OCR (opcional, quítalo en prod)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white.withOpacity(0.8),
              child: Text(_ocrText, style: const TextStyle(fontSize: 10), maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndVerify,
        child: const Icon(Icons.check),
      ),
    );
  }
}