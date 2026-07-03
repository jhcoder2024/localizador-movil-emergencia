# Sprint 4: Visor de conversación y envío

## Sprint Goal
Construir la pantalla de chat completa con burbujas de mensajes, campo de texto, envío de SMS usando SmsManager y actualización en tiempo real.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-013 | Pantalla de conversación con burbujas de chat | 5 | Alta |
| HU-014 | Campo de texto y botón enviar SMS | 3 | Alta |
| HU-015 | Enviar SMS desde la app usando SmsManager | 5 | Alta |
| HU-016 | Actualizar conversación en tiempo real al enviar/recibir | 3 | Alta |

**Total:** 16 puntos (excede capacidad — ver notas abajo)

## Dependencias entre HU
```
HU-013 ──► HU-014 ──► HU-015 ──► HU-016
                                        │
                              HU-007 ───┘ (Sprint 2)
```

## Orden de Ejecución Recomendado
1. **HU-013** (día 1-3): ConversationScreen con burbujas, ConversationProvider, scroll automático.
2. **HU-014** (día 3-4): Campo de texto + botón enviar + optimistic update básico.
3. **HU-015** (día 4-5): Integrar SmsManager para envío real + manejo de errores.
4. **HU-016** (día 5): Actualización en tiempo real + estado de envío (enviando/enviado/fallido).

## Nota sobre capacidad
Este sprint tiene 16 puntos, el doble de la capacidad. **Recomendación:**
- HU-013 y HU-014 son secuenciales pero se pueden solapar parcialmente (empezar HU-014 cuando HU-013 tenga la estructura básica).
- HU-015 es la más crítica — dedicarle tiempo de calidad.
- Si es necesario, mover HU-016 al Sprint 5 (se puede tener un MVP sin tiempo real completo).
- **Alternativa:** Dividir este sprint en 2 sprints de 1 semana si la calidad se ve comprometida.

## Definition of Done (DoD)
- [ ] ConversationScreen muestra burbujas de chat correctamente alineadas
- [ ] El campo de texto permite escribir y enviar mensajes
- [ ] Los SMS se envían realmente usando SmsManager
- [ ] Los mensajes aparecen en la conversación inmediatamente (optimistic update)
- [ ] Los errores de envío se muestran al usuario
- [ ] La conversación se actualiza con SMS entrantes
- [ ] Tests de widget para ConversationScreen

## Riesgos
- El envío de SMS puede fallar en Android 14+ si no somos la app default. Manejar este caso con gracia.
- El optimistic update puede causar inconsistencias si el envío falla. Asegurar rollback visual.
- El scroll automático puede ser frustrante si el usuario está leyendo mensajes anteriores.
