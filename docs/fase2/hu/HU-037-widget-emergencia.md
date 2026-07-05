# HU-037: Widget de escritorio — acceso rápido a emergencia

**Como** usuario
**Quiero** tener un widget de acceso rápido al botón de emergencia en la pantalla de inicio
**Para** activar la emergencia sin tener que abrir la app, ahorrando segundos valiosos

**Requerimiento Padre:** REQ-F2-012 (Widget de escritorio)

**Prioridad:** Baja
**Esfuerzo:** M (2 puntos)

**Dependencias:** HU-036 (Widget de conversaciones recientes)

**Criterios de Aceptación:**
- [ ] Existe un widget específico "Emergencia" en el selector de widgets de Android
- [ ] El widget es de tamaño fijo 2x1 o 2x2 celdas
- [ ] El widget muestra un botón grande con el texto "🚨 EMERGENCIA" en rojo
- [ ] Al tocar el widget, se abre la app directamente en la pantalla de selección de tipo de emergencia
- [ ] Opcional: al tocar el widget, se activa directamente la emergencia con el último tipo usado (configurable)
- [ ] El widget tiene un indicador visual de si hay una emergencia activa:
  - Emergencia activa: botón pulsante/animado con texto "EMERGENCIA ACTIVA"
  - Emergencia inactiva: botón estático con texto "EMERGENCIA"
- [ ] El widget se actualiza cuando cambia el estado de la emergencia
- [ ] El widget respeta el modo oscuro/claro del sistema
- [ ] El widget es claramente visible y distinguible en el escritorio

**Capa técnica requerida:**
- **Android nativo:** Segundo AppWidgetProvider para el widget de emergencia
- **Flutter:** Comunicación con `HomeWidget` para actualizar estado

**Notas técnicas:**
- Reutilizar la infraestructura de `home_widget` creada en HU-036
- El widget de emergencia puede ser un widget independiente o una variante del widget de conversaciones
- Para la animación de emergencia activa, usar un `RemoteViews` con actualización periódica
- Considerar que el widget de emergencia es el diferenciador clave de la app — debe ser visualmente impactante
- Al tocar el widget, pasar un `emergency_action` como extra en el Intent para que la app sepa que debe abrir la pantalla de emergencia
- Configuración: permitir al usuario elegir si el widget activa directamente la emergencia o abre la pantalla de selección
