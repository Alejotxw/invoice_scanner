class Invoice {
  String? fechaEmision;
  double? montoTotal;
  String? codigoFactura;

  Invoice({
    this.fechaEmision,
    this.montoTotal,
    this.codigoFactura,
  });

  // Método para convertir a Map (útil para guardar o enviar)
  Map<String, dynamic> toMap() {
    return {
      'fechaEmision': fechaEmision,
      'montoTotal': montoTotal,
      'codigoFactura': codigoFactura,
    };
  }
}