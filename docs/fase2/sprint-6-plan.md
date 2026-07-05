# Sprint 6: Fundación visual — MMS, Modo oscuro y Material Design 3

## Sprint Goal
Establecer la base visual de la Fase 2: implementar la lectura de MMS (arrastrado de Fase 1), agregar modo oscuro completo y migrar toda la UI a Material Design 3 con Material You.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-021 | Leer y mostrar MMS básicos (imágenes) en la conversación | L (3) | Alta |
| HU-022 | Modo oscuro completo con persistencia de preferencia | M (2) | Alta |
| HU-023 | Migración a Material Design 3 con Material You | L (3) | Alta |

**Total:** 8 puntos ✅

## Dependencias entre HU
```
HU-022 (Modo oscuro) ──► HU-023 (MD3)
HU-021 (MMS lectura) ── (independiente)
```

## Orden de Ejecución Recomendado
1. **HU-022** (día 1-2): Modo oscuro. Es la base de HU-023 y tiene menos dependencias técnicas.
2. **HU-023** (día 2-4): Migración a MD3. Una vez que el modo oscuro funciona, aplicar los componentes M3.
3. **HU-021** (día 3-5): MMS básico. Es independiente y se puede trabajar en paralelo parcial.

## Notas
- HU-021 ya tiene criterios de aceptación definidos desde la Fase 1 — revisar si aplican cambios.
- La migración a MD3 debe verificar que `useMaterial3: true` ya está configurado y solo falta ajustar componentes.
- El modo oscuro debe probarse en todas las pantallas existentes (inbox, conversación, emergencia, configuración).

## Definition of Done (Sprint 6)
- [ ] Los MMS con imágenes se leen del ContentProvider y se muestran en la conversación
- [ ] El modo oscuro funciona con toggle de 3 estados (Claro/Oscuro/Sistema)
- [ ] Todas las pantallas se ven correctamente en modo oscuro
- [ ] La UI sigue las guías de Material Design 3 en todos los componentes
- [ ] Los colores dinámicos (Material You) se aplican en Android 12+
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
- [ ] Todos los tests existentes siguen pasando
