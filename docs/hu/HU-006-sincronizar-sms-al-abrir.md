# HU-006: Sincronizar SMS al abrir la app (primera carga)

**Como** usuario
**Quiero** que al abrir la app, los SMS se sincronicen automáticamente desde el ContentProvider
**Para** tener siempre mi bandeja de entrada actualizada sin acciones manuales

**Requerimiento Padre:** REQ-001.2 (Sincronización con ContentProvider)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-005

**Criterios de Aceptación:**
- [ ] Al iniciar la app (después del splash), se ejecuta automáticamente la sincronización de SMS
- [ ] La primera sincronización (fresh install) importa todos los SMS históricos del ContentProvider
- [ ] Las sincronizaciones posteriores solo importan SMS nuevos (basado en `date` > última sincronización)
- [ ] Se guarda un timestamp de última sincronización en `SharedPreferences` o en la tabla `config`
- [ ] La sincronización se ejecuta en segundo plano (Isolate o compute) para no bloquear la UI
- [ ] Se muestra un indicador de progreso (SnackBar o indicador sutil) durante la primera sincronización si hay más de 100 SMS
- [ ] Si el permiso `READ_SMS` no está concedido, se solicita al usuario antes de sincronizar
- [ ] La sincronización no interfiere con la funcionalidad de emergencia existente

**Notas técnicas:**
- Usar `Future(() => ...)` o `compute()` para la sincronización pesada
- Para sincronizaciones incrementales, guardar `ultimaSincronizacion` en la tabla `config` con clave `last_sms_sync_timestamp`
- La sincronización debe ser tolerante a errores: si falla, no debe impedir que la app cargue
- Considerar que en la primera sincronización puede haber miles de SMS — usar batch inserts con Drift
