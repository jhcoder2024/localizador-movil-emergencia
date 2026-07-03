# HU-008: Marcar SMS como leídos

**Como** usuario
**Quiero** que los mensajes se marquen automáticamente como leídos cuando abro una conversación
**Para** saber qué mensajes he visto y cuáles están pendientes

**Requerimiento Padre:** REQ-001.2 (Sincronización con ContentProvider)

**Prioridad:** Media
**Esfuerzo:** 2 puntos

**Dependencias:** HU-007

**Criterios de Aceptación:**
- [ ] Al abrir una conversación (pantalla de chat), todos los mensajes no leídos de esa conversación se marcan como `leido = true`
- [ ] El contador `noLeidos` de la conversación se resetea a 0 al abrirla
- [ ] El cambio se refleja inmediatamente en la lista de conversaciones (el badge de no leídos desaparece)
- [ ] También se actualiza el ContentProvider de Android (marcar como leído en el sistema) para mantener consistencia
- [ ] Existe un método `markAsRead(String conversationId)` en el repositorio que:
  - Actualiza `leido = true` en todos los `sms_messages` de esa conversación
  - Actualiza `noLeidos = 0` en la conversación
  - Notifica al ContentProvider de Android vía MethodChannel

**Notas técnicas:**
- Para marcar como leído en el ContentProvider de Android:
  ```kotlin
  val values = ContentValues().apply { put(Telephony.Sms.READ, 1) }
  contentResolver.update(Telephony.Sms.CONTENT_URI, values, "_id=?", arrayOf(smsId.toString()))
  ```
- Esto asegura consistencia si el usuario cambia de app SMS
- No es necesario marcar como leído en el ContentProvider si la app no es la predeterminada aún (pero es buena práctica hacerlo)
