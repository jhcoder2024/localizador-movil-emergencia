# Sprint 9: Productividad — Respuesta rápida y Mensajes programados

## Sprint Goal
Aumentar la productividad del usuario permitiéndole responder SMS sin abrir la app (desde la notificación) y programar envíos de SMS para el futuro.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-030 | Respuesta rápida desde la notificación | L (3) | Media |
| HU-031 | Mensajes programados (crear, listar, cancelar) | XL (5) | Media |

**Total:** 8 puntos ✅

## Dependencias entre HU
```
HU-007 (Notif F1) ──► HU-030 (Respuesta rápida)
HU-013 (Chat F1)  ──► HU-030
HU-015 (Enviar F1) ──► HU-031 (Programados)
```

## Orden de Ejecución Recomendado
1. **HU-030** (día 1-3): Respuesta rápida. Requiere trabajo nativo (Android) con `RemoteInput`.
2. **HU-031** (día 3-5): Mensajes programados. Requiere `workmanager` y nueva tabla en Drift.

## Notas
- HU-030 requiere código nativo Android (Kotlin/Java) para el `RemoteInput` del `BroadcastReceiver`.
- Alternativa simplificada para HU-030: usar `Intent.ACTION_SENDTO` con `sms:` URI (menos integrado pero más rápido de implementar).
- HU-031 requiere una nueva tabla `scheduled_messages` en Drift — planificar la migración.
- `workmanager` es la opción recomendada para el envío programado en segundo plano.
- Si HU-029 (MMS audio/video) se movió del Sprint 8, incluirla aquí como prioridad adicional.

## Definition of Done (Sprint 9)
- [ ] El usuario puede responder SMS directamente desde la notificación
- [ ] La respuesta desde notificación actualiza la conversación en la BD
- [ ] El usuario puede programar un SMS para fecha/hora futura
- [ ] Los mensajes programados se envían automáticamente a la hora indicada
- [ ] El usuario puede ver, cancelar y gestionar mensajes programados
- [ ] Los mensajes programados persisten al reiniciar el dispositivo
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
- [ ] Todos los tests existentes siguen pasando
