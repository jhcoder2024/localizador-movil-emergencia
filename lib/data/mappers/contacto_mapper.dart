import 'package:drift/drift.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';
import 'package:localizador_movil_emergencia/data/models/contacto_model.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';

class ContactoMapper {
  static ContactoEmergencia toEntity(ContactoModel model) =>
      ContactoEmergencia(
        id: model.id,
        nombre: model.nombre,
        telefono: model.telefono,
        tieneWhatsApp: model.tieneWhatsApp,
        tieneTelegram: model.tieneTelegram,
        chatIdTelegram: model.chatIdTelegram,
      );

  static ContactoModel toModel(ContactoEmergencia entity) => ContactoModel(
        id: entity.id,
        nombre: entity.nombre,
        telefono: entity.telefono,
        tieneWhatsApp: entity.tieneWhatsApp,
        tieneTelegram: entity.tieneTelegram,
        chatIdTelegram: entity.chatIdTelegram,
      );

  static ContactosTableCompanion toCompanion(ContactoEmergencia entity) =>
      ContactosTableCompanion(
        id: Value(entity.id),
        nombre: Value(entity.nombre),
        telefono: Value(entity.telefono),
        tieneWhatsApp: Value(entity.tieneWhatsApp),
        tieneTelegram: Value(entity.tieneTelegram),
        chatIdTelegram: Value(entity.chatIdTelegram),
      );

  static ContactoEmergencia fromTableData(ContactosTableData row) =>
      ContactoEmergencia(
        id: row.id,
        nombre: row.nombre,
        telefono: row.telefono,
        tieneWhatsApp: row.tieneWhatsApp,
        tieneTelegram: row.tieneTelegram,
        chatIdTelegram: row.chatIdTelegram,
      );

  static List<ContactoEmergencia> toEntityList(List<ContactoModel> models) =>
      models.map(toEntity).toList();

  static List<ContactoEmergencia> fromTableDataList(
          List<ContactosTableData> rows) =>
      rows.map(fromTableData).toList();
}
