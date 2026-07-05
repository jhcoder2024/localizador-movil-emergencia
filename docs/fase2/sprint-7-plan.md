# Sprint 7: Gestión de conversaciones — Búsqueda, Archivar y Eliminar

## Sprint Goal
Dotar al usuario de herramientas completas para gestionar su bandeja de entrada: buscar mensajes, archivar conversaciones para ordenar la bandeja, y eliminar contenido no deseado.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-024 | Búsqueda de conversaciones y mensajes | XL (5) | Alta |
| HU-025 | Archivar y desarchivar conversaciones | M (2) | Alta |
| HU-026 | Eliminar conversaciones con confirmación | S (1) | Alta |

**Total:** 8 puntos ✅

## Dependencias entre HU
```
HU-009 (Inbox F1) ──► HU-024 (Búsqueda)
                    └──► HU-025 (Archivar)
                          └──► HU-026 (Eliminar)
```

## Orden de Ejecución Recomendado
1. **HU-025** (día 1): Archivar. Rápida (2 pts), desbloquea HU-026 y establece el campo `isArchived` en la BD.
2. **HU-026** (día 1-2): Eliminar. Muy rápida (1 pt), depende de la infraestructura de HU-025.
3. **HU-024** (día 2-5): Búsqueda. Es la HU más grande del sprint (5 pts). Dedicar el resto de la semana.

## Notas
- HU-024 (Búsqueda) es la más compleja del sprint. Considerar dividir en sub-tareas si es necesario:
  - Día 2-3: FTS5 en Drift + backend de búsqueda
  - Día 3-4: UI de búsqueda (barra, resultados, resaltado)
  - Día 4-5: Navegación al mensaje encontrado + pulido
- HU-025 requiere migración de BD (ALTER TABLE). Asegurar que la migración sea backward-compatible.
- La búsqueda debe funcionar offline y ser rápida (<500ms para 1000+ mensajes).

## Definition of Done (Sprint 7)
- [ ] El usuario puede buscar mensajes por texto en todas las conversaciones
- [ ] Los resultados se muestran con el término resaltado
- [ ] Al tocar un resultado, se navega a la conversación en el mensaje encontrado
- [ ] El usuario puede archivar y desarchivar conversaciones
- [ ] Las conversaciones archivadas tienen su propia sección
- [ ] Al recibir un nuevo mensaje de una conversación archivada, se desarchiva automáticamente
- [ ] El usuario puede eliminar conversaciones y mensajes individuales con confirmación
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
- [ ] Todos los tests existentes siguen pasando
