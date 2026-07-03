# HU-019: Solicitar ser app SMS predeterminada + flujo de configuración

**Como** usuario
**Quiero** poder establecer esta app como la aplicación de SMS predeterminada de mi dispositivo
**Para** que el botón de emergencia pueda enviar SMS automáticamente

**Requerimiento Padre:** REQ-001.7 (App SMS predeterminada)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-018

**Criterios de Aceptación:**
- [ ] En la pantalla de configuración (`ConfigScreen`), se agrega una sección "App SMS predeterminada" con:
  - Estado actual: "No eres la app SMS predeterminada" o "Eres la app SMS predeterminada ✓"
  - Botón "Establecer como predeterminada" que llama a `solicitarSerSmsDefault()`
- [ ] Al abrir la app por primera vez después de instalar, se muestra un diálogo de bienvenida:
  - "Para que el botón de emergencia funcione automáticamente, establece esta app como tu app de SMS predeterminada"
  - Botones: "Configurar ahora" y "Más tarde"
- [ ] Si el usuario elige "Más tarde", se muestra un recordatorio en la pantalla principal (banner no intrusivo)
- [ ] El método `solicitarSerSmsDefault()` (ya implementado en Kotlin) abre los ajustes de apps predeterminadas
- [ ] Al volver a la app después de cambiar la configuración, se verifica si ahora somos la app default y se actualiza la UI
- [ ] Si la app ya es la predeterminada, se muestra un indicador verde y no se vuelve a preguntar
- [ ] Se agrega un `SmsDefaultProvider` o se extiende `ConfigProvider` para manejar este estado

**Notas técnicas:**
- El método `esAppSmsDefault()` ya existe en `SmsRepository` y en `MainActivity.kt`
- El método `solicitarSerSmsDefault()` ya existe y abre `Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS`
- Verificar el estado al reanudar la app (ciclo de vida `onResume`) usando `WidgetsBindingObserver`
- Guardar en `SharedPreferences` si el usuario ya vio el diálogo de bienvenida (`sms_default_dialog_shown`)
