# HU-021: Leer y mostrar MMS básicos (imágenes) en la conversación

**Como** usuario
**Quiero** ver las imágenes que me envían por MMS dentro de la conversación
**Para** no tener que salir de la app para ver los adjuntos multimedia

**Requerimiento Padre:** REQ-001.6 (MMS básico — solo lectura)

**Prioridad:** Baja
**Esfuerzo:** 5 puntos

**Dependencias:** HU-013

**Criterios de Aceptación:**
- [ ] El `SmsContentProviderDataSource` se extiende para también leer MMS del ContentProvider:
  - Consultar `content://mms/inbox` para MMS recibidos
  - Consultar `content://mms/part` para las partes del MMS (imágenes)
- [ ] Los MMS se importan como mensajes con `tieneMms = true` y un `mmsUrl` que apunta al archivo local
- [ ] Las imágenes MMS se descargan/extraen del ContentProvider y se almacenan en el directorio de caché de la app
- [ ] En la burbuja de chat, los MMS se muestran como:
  - Una imagen en miniatura dentro de la burbuja (en lugar de texto)
  - Al tocar la imagen, se abre en vista completa (usar `showDialog` o navegación a pantalla completa)
- [ ] En la lista de conversaciones, los MMS muestran "📷 Imagen" como preview
- [ ] Los MMS enviados (desde nuestra app) no se implementan en Fase 1 — solo lectura
- [ ] Si la imagen no se puede cargar, se muestra un placeholder con icono de imagen rota

**Notas técnicas:**
- Los MMS en Android se almacenan en una base de datos separada (`content://mms`)
- Para obtener las partes de un MMS:
  ```kotlin
  // Obtener partes del MMS
  val uri = Uri.parse("content://mms/part/$mmsId")
  val cursor = contentResolver.query(uri, null, null, null, null)
  // Si _data no es null, es un archivo adjunto (imagen)
  // Si _data es null, el texto está en el cuerpo
  ```
- Las imágenes MMS pueden estar en `/data/data/com.android.providers.telephony/app_parts/`
- Usar `OpenableColumns` para leer el contenido si la ruta directa no funciona
- Almacenar las imágenes en el directorio de caché de la app (`getCacheDirectory()`) para no saturar el almacenamiento interno
- Considerar usar `cached_network_image` o similar para manejar la carga de imágenes locales
