enum TipoEmergencia {
  extraviado('Emergencia', 'EMG', '¡Emergencia! Estoy en peligro, necesito ayuda.');

  final String displayName;
  final String codigo;
  final String mensajeBase;

  const TipoEmergencia(this.displayName, this.codigo, this.mensajeBase);

  String construirMensaje(double latitud, double longitud) {
    return '$mensajeBase $latitud, $longitud';
  }
}
