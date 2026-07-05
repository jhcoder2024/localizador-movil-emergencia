# HU-029: Recibir y visualizar MMS de audio y video

**Como** usuario
**Quiero** recibir y reproducir mensajes MMS con audio y video
**Para** escuchar notas de voz y ver videos que me envían mis contactos

**Requerimiento Padre:** REQ-F2-007 (MMS completo — recepción multimedia)

**Prioridad:** Alta
**Esfuerzo:** L (3 puntos)

**Dependencias:** HU-021 (Leer y mostrar MMS básicos)

**Criterios de Aceptación:**
- [ ] El `MmsDataSource` se extiende para detectar y procesar partes MMS de tipo:
  - `audio/*` (audio, notas de voz)
  - `video/*` (video)
  - `text/plain` (cuerpo de texto del MMS)
- [ ] Los MMS de audio se muestran en la burbuja como:
  - Un reproductor de audio con: botón play/pause, barra de progreso, duración total
  - Icono de nota de voz (🎤) cuando es audio
- [ ] Los MMS de video se muestran en la burbuja como:
  - Un thumbnail del video con icono de play superpuesto
  - Al tocar, se abre un reproductor de video a pantalla completa
- [ ] Los MMS mixtos (texto + imagen/audio/video) se muestran correctamente:
  - El texto aparece arriba, el adjunto multimedia abajo
- [ ] Los archivos multimedia se almacenan en el directorio de caché de la app
- [ ] Si el archivo es muy grande (>10MB para video), se muestra un mensaje de advertencia
- [ ] Si el formato no es soportado, se muestra un placeholder con el nombre del archivo
- [ ] La reproducción de audio continúa aunque el usuario navegue a otra pantalla (opcional)

**Nuevas dependencias:**
- `chewie: ^1.7.0` (reproductor de video basado en video_player)
- `video_player: ^2.8.0` (reproducción de video)
- `audioplayers: ^6.0.0` (ya incluida en el proyecto)

**Notas técnicas:**
- Reutilizar `audioplayers` que ya está en el proyecto para reproducción de audio
- Para video, `video_player` + `chewie` dan una experiencia completa con controles
- Los archivos multimedia MMS se extraen del ContentProvider igual que las imágenes
- Considerar almacenar en caché con límite de tamaño (ej: 100MB máximo) y limpiar los más antiguos
- Para notas de voz, mostrar forma de onda simple (opcional, puede ser en versión futura)
- Los MMS de audio típicamente son AMR o AAC; los videos son 3GP o MP4
