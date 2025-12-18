import 'package:invoice_scanner/models/invoice_models.dart';
import 'package:invoice_scanner/utils/regex_utils.dart';

class InvoiceParser {
  static Invoice parse(String textoCrudo) {
    final invoice = Invoice();

    // Extraer fechas (sin cambios)
    final fechasMatches = RegexUtils.fechaRegex.allMatches(textoCrudo);
    if (fechasMatches.isNotEmpty) {
      invoice.fechaEmision = fechasMatches.first.group(0);
    }

    // Extraer montos: Mejora - solo si tienen $ o decimales
    final montosMatches = RegexUtils.montoRegex.allMatches(textoCrudo);
    List<double> montos = [];
    for (var match in montosMatches) {
      final matchStr = match.group(0)!;  // Grupo completo para chequeo
      final montoStr = match.group(1)!.replaceAll(',', '').replaceAll(r'$', '');
      final montoNum = double.tryParse(montoStr) ?? 0.0;
      if (montoNum > 0 && (matchStr.contains('.') || matchStr.contains(r'$'))) {
        montos.add(montoNum);
      }
    }

    // Heurística para total: Usa regex con \b para evitar "subtotal"
    final totalMatch = RegexUtils.totalKeywordRegex.firstMatch(textoCrudo.toLowerCase());
    double? totalCandidato;
    if (totalMatch != null) {
      final textoDespuesTotal = textoCrudo.substring(totalMatch.start);
      final montosDespues = RegexUtils.montoRegex.allMatches(textoDespuesTotal);
      if (montosDespues.isNotEmpty) {
        final primerMontoStr = montosDespues.first.group(1)!
            .replaceAll(',', '')
            .replaceAll(r'$', '');
        totalCandidato = double.tryParse(primerMontoStr);
      }
    }

    // Si no hay después de "total", toma el más alto
    if (totalCandidato == null && montos.isNotEmpty) {
      totalCandidato = montos.reduce((a, b) => a > b ? a : b);
    }
    invoice.montoTotal = totalCandidato;

    // Código (sin cambios)
    final codigosMatches = RegexUtils.codigoRegex.allMatches(textoCrudo);
    if (codigosMatches.isNotEmpty) {
      invoice.codigoFactura = codigosMatches.first.group(0);
    }

    return invoice;
  }
}