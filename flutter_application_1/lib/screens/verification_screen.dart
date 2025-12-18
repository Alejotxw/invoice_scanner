import 'package:flutter/material.dart';
import 'package:invoice_scanner/models/invoice_models.dart';

class VerificationScreen extends StatefulWidget {
  final Invoice invoice;
  const VerificationScreen({super.key, required this.invoice});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final TextEditingController _fechaController;
  late final TextEditingController _montoController;
  late final TextEditingController _codigoController;

  @override
  void initState() {
    super.initState();
    _fechaController = TextEditingController(text: widget.invoice.fechaEmision ?? '');
    _montoController = TextEditingController(text: widget.invoice.montoTotal?.toString() ?? '');
    _codigoController = TextEditingController(text: widget.invoice.codigoFactura ?? '');
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _montoController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  void _guardar() {
    // Aquí puedes guardar el Invoice actualizado (e.g., a DB o API)
    final invoiceActualizado = Invoice(
      fechaEmision: _fechaController.text,
      montoTotal: double.tryParse(_montoController.text) ?? 0.0,
      codigoFactura: _codigoController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos guardados exitosamente')),
    );
    // Navega de vuelta o cierra
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar y Editar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(labelText: 'Fecha de Emisión'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(labelText: 'Monto Total'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codigoController,
              decoration: const InputDecoration(labelText: 'Código de Factura (Opcional)'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}