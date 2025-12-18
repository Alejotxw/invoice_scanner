import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  // Para ImageSource
import 'package:invoice_scanner/screens/scan_screen.dart';
import 'package:invoice_scanner/screens/live_scan_screen.dart';  // Para modo vivo

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Scanning OCR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanScreen(source: ImageSource.camera),  // Ahora const OK
                ),
              ),
              icon: const Icon(Icons.camera),
              label: const Text('Escanear con Cámara (Estático)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanScreen(source: ImageSource.gallery),  // Ahora const OK
                ),
              ),
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar de Galería'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LiveScanScreen()),  // const si agregas en LiveScanScreen
              ),
              icon: const Icon(Icons.videocam),
              label: const Text('Escanear en Vivo (Tiempo Real)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}