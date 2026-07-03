# HU-010: Ordenar conversaciones por fecha del último mensaje

**Como** usuario
**Quiero** que las conversaciones aparezcan ordenadas por la fecha del último mensaje (más reciente primero)
**Para** ver rápidamente las conversaciones activas

**Requerimiento Padre:** REQ-001.3 (Bandeja de entrada)

**Prioridad:** Alta
**Esfuerzo:** 2 puntos

**Dependencias:** HU-009

**Criterios de Aceptación:**
- [ ] La lista de conversaciones se ordena por `ultimaFecha` descendente (más reciente al inicio)
- [ ] El orden se mantiene automáticamente cuando llega un nuevo SMS (la conversación se mueve al tope)
- [ ] Si dos conversaciones tienen la misma fecha exacta, se ordenan alfabéticamente por remitente
- [ ] El orden es consistente entre reinicios de la app

**Notas técnicas:**
- El orden debe aplicarse en la consulta SQL de Drift (`ORDER BY ultimaFecha DESC`)
- Si se ordena en Dart, asegurar que sea un ordenamiento estable
- La reactividad de Drift (`watch()`) ya re-emite la lista cuando hay cambios
