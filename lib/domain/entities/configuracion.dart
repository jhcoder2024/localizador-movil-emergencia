import 'package:equatable/equatable.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';

/// Configuración de la aplicación.
///
/// ## Ahorro de batería
/// - El intervalo de envío nunca debe ser menor a [intervaloMinimo] (5 minutos).
class Configuracion extends Equatable {
  final int intervaloMinutos;
  final List<ContactoEmergencia> contactos;
  final String idioma;
  final String? telegramToken;

  static const int intervaloMinimo = 5;
  static const int intervaloDefault = 5;
  static const int maxContactos = 10;

  const Configuracion({
    this.intervaloMinutos = intervaloDefault,
    this.contactos = const [],
    this.idioma = 'es',
    this.telegramToken,
  });

  bool get esValida =>
      intervaloMinutos >= intervaloMinimo &&
      contactos.isNotEmpty &&
      contactos.length <= maxContactos;

  Configuracion copyWith({
    int? intervaloMinutos,
    List<ContactoEmergencia>? contactos,
    String? idioma,
    String? telegramToken,
  }) {
    return Configuracion(
      intervaloMinutos: intervaloMinutos ?? this.intervaloMinutos,
      contactos: contactos ?? this.contactos,
      idioma: idioma ?? this.idioma,
      telegramToken: telegramToken ?? this.telegramToken,
    );
  }

  @override
  List<Object?> get props => [
        intervaloMinutos,
        contactos,
        idioma,
        telegramToken,
      ];
}
