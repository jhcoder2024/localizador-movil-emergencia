# Sprint 3: Bandeja de entrada (Inbox)

## Sprint Goal
Construir la pantalla principal de la app de SMS: la lista de conversaciones con toda la información relevante (remitente, preview, hora, no leídos) y navegación básica.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-009 | Pantalla de lista de conversaciones (Inbox) | 5 | Alta |
| HU-010 | Ordenar conversaciones por fecha del último mensaje | 2 | Alta |
| HU-011 | Mostrar remitente, preview y hora en cada conversación | 3 | Alta |
| HU-012 | Navegar al tocar una conversación | 2 | Alta |

**Total:** 12 puntos (excede capacidad — ver notas abajo)

## Dependencias entre HU
```
HU-009 ──► HU-010
  │
  ├──► HU-011
  │
  └──► HU-012
```

## Orden de Ejecución Recomendado
1. **HU-009** (día 1-3): Crear InboxScreen, InboxProvider, integrar con el router. Esta es la HU más grande del sprint.
2. **HU-011** (día 3-4): Agregar remitente, preview y hora a los tiles. Depende de tener la lista funcionando.
3. **HU-010** (día 4): Asegurar orden correcto. Se puede hacer en paralelo con HU-011.
4. **HU-012** (día 5): Navegación a ConversationScreen (placeholder). Depende de HU-009 completa.

## Nota sobre capacidad
Este sprint tiene 12 puntos. **Recomendación:**
- HU-010 y HU-011 son relativamente pequeñas y se pueden hacer en paralelo.
- Si el tiempo es ajustado, HU-012 se puede simplificar (navegación básica sin transiciones elaboradas).
- Considerar mover HU-010 al Sprint 2 si HU-008 se movió aquí.

## Definition of Done (DoD)
- [ ] InboxScreen muestra la lista de conversaciones
- [ ] Las conversaciones se ordenan por fecha descendente
- [ ] Cada tile muestra remitente, preview, hora y badge de no leídos
- [ ] Al tocar una conversación, navega a ConversationScreen (placeholder)
- [ ] La lista se actualiza en tiempo real
- [ ] Estado vacío funciona correctamente
- [ ] Tests de widget para InboxScreen

## Riesgos
- La resolución de nombres de contacto puede ser lenta si hay muchos contactos. Cachear resultados.
- El rendimiento de la lista puede degradarse con miles de conversaciones. Considerar `ListView.builder` con paginación.
