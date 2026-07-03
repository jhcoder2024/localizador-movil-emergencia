# HU-003: Repositorio SmsRepository con operaciones de inbox

**Como** desarrollador
**Quiero** crear la interfaz `SmsInboxRepository` en domain y su implementación en data con los DAOs de Drift
**Para** abstraer el acceso a los SMS locales y permitir operaciones CRUD desde la capa de presentación

**Requerimiento Padre:** REQ-001.1 (Base de datos SMS)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-002

**Criterios de Aceptación:**
- [ ] Existe la interfaz `SmsInboxRepository` en `lib/domain/repositories/` con métodos:
  - `Stream<List<Conversation>> watchConversations()` — observable de todas las conversaciones
  - `Stream<List<SmsMessage>> watchMessages(String conversationId)` — observable de mensajes de una conversación
  - `Future<void> insertMessage(SmsMessage message)` — insertar un mensaje
  - `Future<void> insertMessages(List<SmsMessage> messages)` — insertar múltiples mensajes (batch)
  - `Future<void> markAsRead(String conversationId)` — marcar todos los mensajes como leídos
  - `Future<void> upsertConversation(Conversation conversation)` — crear o actualizar una conversación
- [ ] Existe `SmsInboxRepositoryImpl` en `lib/data/repositories/` que implementa la interfaz usando `SmsDao` y `ConversationDao`
- [ ] Existen los DAOs `SmsDao` y `ConversationDao` en `lib/data/datasources/local/` con operaciones CRUD básicas
- [ ] Existen los mappers para convertir entre modelos Drift y entidades de dominio
- [ ] El repositorio se registra en `data_module.dart` con GetIt
- [ ] Los tests unitarios del repositorio pasan (usar Mocktail para mockear DAOs)

**Notas técnicas:**
- `watchConversations()` debe emitir la lista ordenada por `ultimaFecha` descendente
- `watchMessages()` debe emitir la lista ordenada por `fecha` ascendente
- Usar `Stream` de Drift (`watch()` en las consultas) para reactividad
- Los mappers deben estar en `lib/data/mappers/sms_mappers.dart`
- El `SmsInboxRepository` es **nuevo** y diferente del `SmsRepository` existente (que solo tiene `enviarSms`, `estaDisponible`, etc.)
