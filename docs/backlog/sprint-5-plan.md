# Sprint 5: Emergencia automática y pulido

## Sprint Goal
Integrar el botón de emergencia en la nueva interfaz de SMS, habilitar el envío automático de emergencia (sin abrir otra app), guiar al usuario para establecer la app como SMS predeterminada, y pulir la experiencia general.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-017 | Botón de emergencia integrado en la bandeja (FAB) | 3 | Alta |
| HU-018 | Enviar SMS de emergencia automáticamente | 5 | Alta |
| HU-019 | Solicitar ser app SMS predeterminada + flujo de configuración | 3 | Alta |
| HU-020 | Ajustes UI/UX y pulido general | 3 | Media |
| HU-021 | Leer y mostrar MMS básicos (imágenes) en la conversación | 5 | Baja |

**Total:** 19 puntos (excede capacidad — ver notas abajo)

## Dependencias entre HU
```
HU-017 ──► HU-018 ──► HU-019
  │
  └──► HU-020 (depende de todo lo anterior para pulir)
  
HU-021 (independiente, se puede hacer en cualquier momento)
```

## Orden de Ejecución Recomendado
1. **HU-017** (día 1-2): HomeScreen con BottomNavigationBar + FAB de emergencia en Inbox.
2. **HU-018** (día 2-4): Modificar EnviarUbicacionUseCase para envío directo. Esta es la HU más crítica del sprint.
3. **HU-019** (día 4-5): Flujo de configuración de app default + diálogos.
4. **HU-020** (día 5): Pulido general, locales, tests.
5. **HU-021** (si hay tiempo): MMS básico — si no entra, mover a Fase 2.

## Nota sobre capacidad
Este sprint tiene 19 puntos. **Estrategia recomendada:**
- **HU-021 (MMS) es candidato #1 para mover a Fase 2** si el tiempo es ajustado. Es la de menor prioridad (Could).
- HU-017 y HU-019 son relativamente rápidas (3 pts cada una).
- HU-018 es la más importante de toda la Fase 1 — dedicarle el tiempo necesario.
- Si HU-016 no se completó en Sprint 4, incluirla aquí como prioridad.

## Definition of Done (Fase 1 Completa)
- [ ] La app tiene bandeja de entrada de SMS funcional
- [ ] Se pueden leer y enviar SMS
- [ ] Los SMS entrantes se reciben en tiempo real
- [ ] El botón de emergencia envía SMS automáticamente (sin abrir otra app)
- [ ] La app se puede establecer como SMS predeterminada
- [ ] La app aparece en la lista de apps SMS de Android
- [ ] Todos los tests existentes siguen pasando
- [ ] La funcionalidad de emergencia existente (sonido, notificaciones, GPS) sigue funcionando

## Criterios de Aceptación de la Fase 1
- [ ] Un usuario puede abrir la app, ver sus conversaciones, leer mensajes y responder
- [ ] Un usuario puede activar una emergencia y los SMS se envían automáticamente
- [ ] Un usuario puede establecer la app como SMS predeterminada desde Configuración
- [ ] La app funciona correctamente en Android 14+
