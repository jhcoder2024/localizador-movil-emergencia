# Sprint 11: Widget de escritorio — Conversaciones y Emergencia

## Sprint Goal
Proporcionar acceso rápido desde la pantalla de inicio con dos widgets: uno para ver conversaciones recientes y otro para activar la emergencia sin abrir la app.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-036 | Widget de escritorio: conversaciones recientes | L (3) | Baja |
| HU-037 | Widget de escritorio: acceso rápido a emergencia | M (2) | Baja |

**Total:** 5 puntos ✅ (por debajo de capacidad — ver notas)

## Dependencias entre HU
```
HU-009 (Inbox F1) ──► HU-036 (Widget conversaciones)
HU-036 ──► HU-037 (Widget emergencia)
```

## Orden de Ejecución Recomendado
1. **HU-036** (día 1-3): Widget de conversaciones. Establece la infraestructura base con `home_widget`.
2. **HU-037** (día 3-5): Widget de emergencia. Reutiliza la infraestructura de HU-036.

## Notas sobre capacidad
Este sprint tiene solo 5 puntos. **Opciones para completar la capacidad:**
- Incluir HU pendientes de sprints anteriores (ej: HU-029 si no se completó en Sprint 8).
- Agregar tareas de pulido general, testing y documentación.
- Realizar una semana de "bug bash" para corregir issues acumulados.
- Preparar el release de la Fase 2 (testing de integración, optimizaciones).

## Notas técnicas
- `home_widget` es el plugin recomendado para widgets en Flutter.
- El widget de conversaciones debe actualizarse al recibir nuevos SMS.
- El widget de emergencia debe reflejar el estado actual de la emergencia (activa/inactiva).
- Probar en múltiples tamaños de widget y launchers (Pixel Launcher, Samsung One UI, Nova, etc.).
- Los widgets tienen limitaciones en algunos launchers personalizados — documentar compatibilidad.

## Definition of Done (Sprint 11)
- [ ] El widget de conversaciones muestra las últimas conversaciones en el escritorio
- [ ] Al tocar una conversación en el widget, se abre la app en esa conversación
- [ ] El widget de emergencia permite activar la emergencia desde el escritorio
- [ ] El widget de emergencia muestra el estado actual (activa/inactiva)
- [ ] Ambos widgets respetan el modo oscuro del sistema
- [ ] Los widgets se actualizan automáticamente al recibir nuevos mensajes
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
- [ ] Todos los tests existentes siguen pasando

## Criterios de Aceptación de la Fase 2 (Completa)
- [ ] La app tiene modo oscuro y sigue Material Design 3 con Material You
- [ ] El usuario puede buscar mensajes en todas las conversaciones
- [ ] El usuario puede archivar, eliminar y gestionar conversaciones
- [ ] El usuario puede enviar y recibir MMS (fotos, audio, video)
- [ ] El usuario puede responder SMS desde la notificación
- [ ] El usuario puede programar envíos de SMS
- [ ] El usuario puede bloquear números de spam
- [ ] El usuario puede exportar/importar sus SMS
- [ ] La app tiene widgets de conversaciones y emergencia
- [ ] La funcionalidad de emergencia sigue funcionando correctamente en todas las pantallas nuevas
