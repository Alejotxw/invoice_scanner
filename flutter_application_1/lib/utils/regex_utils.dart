class RegexUtils {
  // Regex para fechas: Soporta DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD
  static final RegExp fechaRegex = RegExp(
    r'\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[-/]\d{1,2}[-/]\d{1,2})\b',
    caseSensitive: false,
  );

  // Regex para montos: Captura $123.45, 1,234.56, etc. (con o sin $)
  static final RegExp montoRegex = RegExp(
    r'\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
    caseSensitive: false,
  );

  // Regex para código de factura: Patrones alfanuméricos como 001-001-123456789
  static final RegExp codigoRegex = RegExp(
    r'\b[A-Z0-9]{3}-[A-Z0-9]{3}-[A-Z0-9]{9}\b',
    caseSensitive: false,
  );

  // Palabras clave para identificar "Total" (insensible a mayúsculas)
  static final RegExp totalKeywordRegex = RegExp(
    r'\b(total|tot|suma|payable|to pay)\b',
    caseSensitive: false,
  );
}