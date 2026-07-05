# HU-036: Widget de escritorio — conversaciones recientes

**Como** usuario
**Quiero** tener un widget en la pantalla de inicio que muestre mis conversaciones más recientes
**Para** acceder rápidamente a mis chats sin abrir la app

**Requerimiento Padre:** REQ-F2-012 (Widget de escritorio)

**Prioridad:** Baja
**Esfuerzo:** L (3 puntos)

**Dependencias:** HU-009 (Pantalla de lista de conversaciones)

**Criterios de Aceptación:**
- [ ] El widget está disponible en el selector de widgets de Android
- [ ] El widget tiene un tamaño configurable (4x1, 4x2, 4x3 celdas)
- [ ] El widget muestra las últimas N conversaciones (según el tamaño):
  - 4x1: 1 conversación + contador de no leídos
  - 4x2: 3 conversaciones
  - 4x3: 6 conversaciones
- [ ] Cada conversación en el widget muestra:
  - Nombre del contacto (o número)
  - Preview del último mensaje (máximo 50 caracteres)
  - Hora del último mensaje
  - Indicador de mensajes no leídos (badge rojo con número)
- [ ] Al tocar una conversación en el widget, se abre la app directamente en esa conversación
- [ ] El widget se actualiza automáticamente al recibir nuevos mensajes
- [ ] El widget tiene un tema que respeta el modo oscuro/claro del sistema
- [ ] El widget tiene un fondo semitransparente que se adapta al wallpaper (Android 12+)
- [ ] Si no hay conversaciones, el widget muestra "Sin conversaciones" con el logo de la app
- [ ] El widget no consume batería excesiva (actualización mínima, usar caché)

**Nuevas dependencias:**
- `home_widget: ^0.6.0` (plugin para widgets de Android/iOS en Flutter)

**Capa técnica requerida:**
- **Android nativo:** Proveedor de widget (AppWidgetProvider) en Kotlin/Java
- **Flutter:** `HomeWidget` plugin para comunicación bidireccional entre widget y app
- **Data:** El widget consulta las conversaciones desde la BD Drift (o desde un caché en SharedPreferences)

**Notas técnicas:**
- `home_widget` es el plugin más popular para widgets en Flutter
- El widget se implementa en código nativo Android (XML + Kotlin) con datos proporcionados por Flutter
- Flujo de datos:
  1. La app escribe los datos de las conversaciones en SharedPreferences (vía `HomeWidget.saveWidgetData`)
  2. El widget Android lee esos datos y renderiza el layout
  3. Al tocar un elemento, el widget lanza un Intent que abre la app con el conversationId
- Para actualización en tiempo real: usar `HomeWidget.updateWidget` desde Flutter cuando llegue un nuevo SMS
- Alternativa: usar `AppWidgetManager` directamente con MethodChannels para más control
- El widget debe tener un `updatePeriodMillis` razonable (ej: 30 minutos) como fallback
