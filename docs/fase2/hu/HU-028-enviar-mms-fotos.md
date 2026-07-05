# HU-028: Enviar MMS con fotos desde la galería/cámara

**Como** usuario
**Quiero** enviar fotos por MMS desde la galería o tomar una foto con la cámara
**Para** compartir imágenes con mis contactos sin salir de la app

**Requerimiento Padre:** REQ-F2-007 (MMS completo — envío)

**Prioridad:** Alta
**Esfuerzo:** XL (5 puntos)

**Dependencias:** HU-021 (Leer y mostrar MMS básicos), HU-027 (Editor de texto enriquecido)

**Criterios de Aceptación:**
- [ ] El campo de texto tiene un botón de adjuntar (clip) al lado del botón de emoji
- [ ] Al tocar el botón de adjuntar, se muestra un bottom sheet con opciones:
  - "Galería" → abre el selector de imágenes del sistema
  - "Cámara" → abre la cámara para tomar una foto
- [ ] Al seleccionar una imagen, se muestra una previsualización dentro del campo de texto (o sobre él)
- [ ] La imagen seleccionada se puede eliminar antes de enviar (icono "X" en la previsualización)
- [ ] Se puede adjuntar 1 imagen por mensaje (límite de MMS estándar)
- [ ] Al enviar, la imagen se comprime a máximo 600KB (límite típico de MMS)
- [ ] El envío MMS se realiza a través de la API de Android:
  - Usar `SmsManager` con `sendMultimediaMessage` (API 21+)
  - O usar `ContentValues` para insertar en `content://mms` (requiere ser app SMS default)
- [ ] La imagen enviada aparece en la conversación como una burbuja con la imagen en miniatura
- [ ] Al tocar la imagen enviada, se abre en vista completa
- [ ] Si el envío falla, se muestra un indicador de error en la burbuja (icono de warning)
- [ ] La imagen se almacena localmente en el directorio de la app para visualización offline

**Nuevas dependencias:**
- `image_picker: ^1.0.0` (seleccionar de galería/cámara)
- `image_compression_flutter` o `flutter_image_compress` (comprimir imágenes)

**Capa técnica requerida:**
- **Data:** Nuevo `MmsDataSource` para manejar el envío MMS, nuevo modelo `MmsPart`
- **Domain:** Nuevo `SendMmsUseCase`, extensión de `SmsMessage` para incluir adjuntos
- **Presentation:** Provider con estado de adjunto, widget de previsualización

**Notas técnicas:**
- El envío de MMS es más complejo que SMS porque requiere configurar un APN y usar la API de `ContentResolver`
- En Android 14+, el envío de MMS puede requerir permisos adicionales
- Alternativa: usar `Intent.ACTION_SEND` para delegar el envío a la app SMS predeterminada del sistema
- La compresión debe mantener una calidad aceptable (80% calidad JPEG, máximo 1920px en el lado más largo)
- Almacenar las imágenes en `getApplicationDocumentsDirectory()` para que persistan
- Considerar usar `cached_network_image` para la visualización (aunque sean locales, maneja bien el caché)
