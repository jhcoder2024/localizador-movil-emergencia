# Sprint 8: Mensajes enriquecidos — Editor, MMS fotos, MMS multimedia

## Sprint Goal
Transformar la experiencia de escritura de mensajes con un editor enriquecido con emojis, y habilitar el envío y recepción completa de MMS (fotos, audio, video).

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos (ideal) / 11 puntos (con paralelización)

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-027 | Editor de texto enriquecido con emojis | L (3) | Alta |
| HU-028 | Enviar MMS con fotos desde la galería/cámara | XL (5) | Alta |
| HU-029 | Recibir y visualizar MMS de audio y video | L (3) | Alta |

**Total:** 11 puntos ⚠️ (excede capacidad ideal)

## Dependencias entre HU
```
HU-014 (Campo texto F1) ──► HU-027 (Editor)
HU-021 (MMS lectura F2) ──► HU-028 (Envío MMS)
                          └──► HU-029 (MMS audio/video)
HU-027 ──► HU-028 (comparten UI del campo de texto)
```

## Orden de Ejecución Recomendado
1. **HU-027** (día 1-2): Editor de texto con emojis. Desbloquea la UI para adjuntar archivos.
2. **HU-028** (día 2-4): Envío de MMS con fotos. Es la HU más grande y compleja del sprint.
3. **HU-029** (día 4-5): Recepción de audio/video. Comparte infraestructura con HU-021 y HU-028.

## Estrategia si el tiempo es ajustado
- **HU-029 es candidato #1 para mover al Sprint 9** si no entra. Es la de menor impacto inmediato (audio/video MMS son menos comunes que fotos).
- HU-027 y HU-028 están fuertemente acopladas (comparten la UI del campo de texto) — hacerlas juntas en el mismo sprint.
- Si se mueve HU-029, el sprint quedaría en 8 pts exactos.

## Notas
- HU-028 requiere nuevas dependencias: `image_picker` y `flutter_image_compress`.
- El envío de MMS es técnicamente complejo en Android. Considerar usar `Intent.ACTION_SEND` como fallback.
- HU-029 reutiliza `audioplayers` (ya incluido) y agrega `video_player` + `chewie`.
- Probar MMS en un dispositivo físico (los emuladores tienen soporte limitado para MMS).

## Definition of Done (Sprint 8)
- [ ] El campo de texto tiene selector de emojis con categorías
- [ ] El usuario puede adjuntar y enviar fotos por MMS
- [ ] Las fotos se comprimen automáticamente para MMS
- [ ] El usuario puede recibir y reproducir audio MMS
- [ ] El usuario puede recibir y ver video MMS
- [ ] Los MMS mixtos (texto + multimedia) se muestran correctamente
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
- [ ] Todos los tests existentes siguen pasando
