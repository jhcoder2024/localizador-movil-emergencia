enum TipoEmergencia {
  extraviado('Extraviado', 'EXT', '¡Emergencia! Estoy extraviado, necesito ayuda.'),
  atrapado('Atrapado', 'ATR', '¡Emergencia! Estoy atrapado, necesito ayuda.'),
  herido('Herido', 'HER', '¡Emergencia! Estoy herido, necesito ayuda médica urgente.');

  final String displayName;
  final String codigo;
  final String mensajeBase;

  const TipoEmergencia(this.displayName, this.codigo, this.mensajeBase);

  String construirMensaje(double latitud, double longitud) {
    return '$mensajeBase geo:$latitud,$longitud';
  }
}
