# HU-001: Tablas `conversations` y `sms_messages` en Drift

**Como** desarrollador
**Quiero** crear las tablas `conversations` y `sms_messages` en la base de datos Drift
**Para** almacenar los SMS de forma local y estructurada

**Requerimiento Padre:** REQ-001.1 (Base de datos SMS)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** Ninguna

**Criterios de Aceptación:**
- [ ] Existe la tabla `conversations` con columnas: `id` (TEXT PK), `remitente` (TEXT), `telefono` (TEXT), `ultimoMensaje` (TEXT), `ultimaFecha` (INTEGER), `noLeidos` (INTEGER default 0)
- [ ] Existe la tabla `sms_messages` con columnas: `id` (INTEGER PK auto), `conversationId` (TEXT FK → conversations.id), `remitente` (TEXT), `telefono` (TEXT), `cuerpo` (TEXT), `fecha` (INTEGER), `tipo` (INTEGER: 1=recibido, 2=enviado), `leido` (BOOLEAN default false), `tieneMms` (BOOLEAN default false)
- [ ] Ambas tablas se registran en la anotación `@DriftDatabase` de `AppDatabase`
- [ ] Se ejecuta `build_runner` y el archivo `app_database.g.dart` se regenera sin errores
- [ ] Las tablas se crean correctamente al iniciar la app (verificable con un test de integración)

**Notas técnicas:**
- La tabla `conversations` usa `id` como el número de teléfono normalizado del remitente (E.164)
- `sms_messages.conversationId` es FK hacia `conversations.id`
- `sms_messages.tipo`: usar constantes `1 = received`, `2 = sent`
- `sms_messages.fecha` se almacena como timestamp Unix en milisegundos
- La columna `tieneMms` permite identificar mensajes que contienen adjuntos multimedia
