import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String remitente;
  final String telefono;
  final String ultimoMensaje;
  final DateTime ultimaFecha;
  final int noLeidos;

  const Conversation({
    required this.id,
    required this.remitente,
    required this.telefono,
    required this.ultimoMensaje,
    required this.ultimaFecha,
    this.noLeidos = 0,
  });

  @override
  List<Object?> get props => [id, remitente, telefono, ultimoMensaje, ultimaFecha, noLeidos];
}
