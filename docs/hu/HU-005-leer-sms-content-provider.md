# HU-005: Leer SMS existentes del ContentProvider de Android

**Como** usuario
**Quiero** que al abrir la app por primera vez, se importen todos mis SMS existentes desde el ContentProvider de Android
**Para** tener mi bandeja de entrada completa sin perder mensajes anteriores

**Requerimiento Padre:** REQ-001.2 (Sincronización con ContentProvider)

**Prioridad:** Alta
**Esfuerzo:** 5 puntos

**Dependencias:** HU-003, HU-004

**Criterios de Aceptación:**
- [ ] Existe un `SmsContentProviderDataSource` en `lib/data/datasources/remote/` (o `platform/`) que consulta el ContentProvider de Android vía MethodChannel
- [ ] El MethodChannel en Kotlin (`MainActivity.kt`) expone un método `getAllSms` que:
  - Consulta `content://sms/inbox` para mensajes recibidos
  - Consulta `content://sms/sent` para mensajes enviados
  - Consulta `content://sms/draft` para borradores (opcional)
  - Retorna una lista de mapas con: `id`, `address`, `body`, `date`, `type` (1=inbox, 2=sent), `read`, `threadId`
- [ ] El método `getAllSms` maneja correctamente el permiso `READ_SMS` (retorna error si no está concedido)
- [ ] Los SMS se devuelven en lotes (paginación) para no saturar el canal de comunicación
- [ ] Existe un `SmsSyncService` o `SmsSyncUseCase` en la capa de dominio que orquesta la sincronización
- [ ] Los SMS importados se mapean correctamente a las entidades `Conversation` y `SmsMessage`
- [ ] Se evitan duplicados: si un SMS ya existe en la BD local (mismo `id` del ContentProvider), no se re-inserta

**Notas técnicas:**
- El ContentProvider de SMS es propiedad de Android y solo accesible desde Kotlin/Java nativo
- Usar `contentResolver.query(Telephony.Sms.CONTENT_URI, ...)` en Kotlin
- Para evitar saturar el MethodChannel, limitar a 500 SMS por lote y usar un callback de progreso
- El `threadId` del ContentProvider se puede usar para agrupar conversaciones, pero nuestra app usará el número de teléfono como identificador de conversación
- Considerar que algunos dispositivos pueden tener >10,000 SMS — la sincronización debe ser eficiente
