# Sprint 10: Seguridad y respaldo — Bloqueo de spam y Copia de seguridad

## Sprint Goal
Proteger al usuario de spam y números no deseados, y proporcionar herramientas para exportar e importar sus mensajes como respaldo.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-032 | Bloqueo de números spam | M (2) | Media |
| HU-033 | Reportar y gestionar conversaciones bloqueadas | M (2) | Media |
| HU-034 | Copia de seguridad: exportar SMS a archivo | M (2) | Baja |
| HU-035 | Copia de seguridad: importar SMS desde archivo | M (2) | Baja |

**Total:** 8 puntos ✅

## Dependencias entre HU
```
HU-009 (Inbox F1) ──► HU-032 (Bloqueo)
HU-032 ──► HU-033 (Gestionar bloqueados)
HU-003 (Repo F1) ──► HU-034 (Exportar)
HU-034 ──► HU-035 (Importar)
```

## Orden de Ejecución Recomendado
1. **HU-032** (día 1-2): Bloqueo de números. Base para HU-033.
2. **HU-033** (día 2-3): Gestión de bloqueados. Depende de HU-032.
3. **HU-034** (día 3-4): Exportar SMS. Independiente de las de bloqueo.
4. **HU-035** (día 4-5): Importar SMS. Depende de HU-034.

## Notas
- HU-032 y HU-033 pueden hacerse como una sola unidad lógica (4 pts total).
- HU-034 y HU-035 también pueden agruparse (4 pts total).
- El bloqueo debe integrarse con el `SmsBroadcastReceiver` para filtrar mensajes entrantes.
- La exportación/importación usa formato JSON. Considerar incluir imágenes MMS como base64 o archivos separados.
- Para la importación, implementar detección de duplicados para no duplicar mensajes existentes.

## Definition of Done (Sprint 10)
- [ ] El usuario puede bloquear números desde la conversación
- [ ] Los mensajes de números bloqueados no aparecen en el inbox ni generan notificaciones
- [ ] El usuario puede ver y gestionar la lista de números bloqueados
- [ ] El usuario puede exportar sus conversaciones a un archivo JSON
- [ ] El usuario puede importar conversaciones desde un archivo JSON
- [ ] Los duplicados se detectan y omiten durante la importación
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
- [ ] Todos los tests existentes siguen pasando
