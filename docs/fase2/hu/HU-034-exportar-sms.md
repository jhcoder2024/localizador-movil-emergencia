# HU-034: Copia de seguridad — exportar SMS a archivo

**Como** usuario
**Quiero** exportar mis conversaciones SMS a un archivo
**Para** tener una copia de seguridad que pueda guardar o transferir a otro dispositivo

**Requerimiento Padre:** REQ-F2-011 (Copia de seguridad)

**Prioridad:** Baja
**Esfuerzo:** M (2 puntos)

**Dependencias:** HU-003 (Repositorio SmsRepository con operaciones de inbox)

**Criterios de Aceptación:**
- [ ] En la pantalla de Configuración, hay una sección "Copia de seguridad"
- [ ] La sección tiene un botón "Exportar SMS" con descripción del formato
- [ ] Al tocar "Exportar", se muestra un diálogo con opciones:
  - Formato: JSON (legible, fácil de procesar) o CSV (compatible con hojas de cálculo)
  - Incluir: "Todas las conversaciones" o "Solo seleccionadas"
  - Adjuntar: "Incluir imágenes MMS" (aumenta el tamaño del archivo)
- [ ] Al confirmar, se genera el archivo y se abre el selector de ubicación del sistema
- [ ] El archivo exportado contiene:
  - Metadatos: fecha de exportación, versión de la app, cantidad de conversaciones
  - Por cada conversación: contacto, número, fecha del último mensaje
  - Por cada mensaje: fecha, hora, tipo (enviado/recibido), contenido, adjuntos MMS (si se incluyen)
- [ ] Los datos sensibles (números de teléfono) se incluyen en texto plano (es una copia de seguridad personal)
- [ ] Se muestra una barra de progreso durante la exportación
- [ ] Al completar, se muestra un mensaje de éxito con la ruta del archivo
- [ ] Si hay errores, se muestran mensajes claros (permiso de almacenamiento, espacio insuficiente, etc.)

**Nuevas dependencias:**
- `share_plus: ^9.0.0` (compartir/guardar archivo)
- `file_picker: ^8.0.0` (selector de ubicación)

**Capa técnica requerida:**
- **Data:** Nuevo `BackupRepository` que serializa los datos de Drift a JSON/CSV
- **Domain:** Nuevo `ExportSmsUseCase`
- **Presentation:** Nueva sección en Configuración, provider para estado de exportación

**Notas técnicas:**
- Formato JSON recomendado por su flexibilidad y facilidad de parseo
- Estructura JSON sugerida:
  ```json
  {
    "appName": "Localizador Móvil de Emergencia",
    "exportDate": "2026-07-05T10:30:00Z",
    "version": "1.0.0",
    "conversations": [
      {
        "contactName": "Juan Pérez",
        "phoneNumber": "+521234567890",
        "messages": [
          {
            "date": "2026-07-04T15:20:00Z",
            "type": "received",
            "content": "Hola, ¿cómo estás?",
            "hasMms": false
          }
        ]
      }
    ]
  }
  ```
- Las imágenes MMS se incluyen como base64 dentro del JSON (aumenta tamaño) o como archivos separados en un ZIP
- Para exportaciones grandes (>100MB), considerar hacerlo en segundo plano con un isolate
- Usar `path_provider` para obtener el directorio temporal y `share_plus` para compartir/guardar
