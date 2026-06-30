import 'package:localizador_movil_emergencia/data/models/configuracion_model.dart';
import 'package:localizador_movil_emergencia/data/models/contacto_model.dart';
import 'package:localizador_movil_emergencia/data/mappers/contacto_mapper.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';

class ConfigMapper {
  static Configuracion toEntity(ConfiguracionModel model) => Configuracion(
        intervaloMinutos: model.intervaloMinutos,
        contactos: model.contactos
            .map((c) => ContactoMapper.toEntity(c))
            .toList(),
        idioma: model.idioma,
        telegramToken: model.telegramToken,
      );

  static ConfiguracionModel toModel(Configuracion entity) =>
      ConfiguracionModel(
        intervaloMinutos: entity.intervaloMinutos,
        contactos: entity.contactos
            .map((c) => ContactoMapper.toModel(c))
            .toList(),
        idioma: entity.idioma,
        telegramToken: entity.telegramToken,
      );
}
