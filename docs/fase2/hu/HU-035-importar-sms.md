# HU-035: Copia de seguridad — importar SMS desde archivo

**Como** usuario
**Quiero** importar mis conversaciones SMS desde un archivo de respaldo
**Para** restaurar mis mensajes al cambiar de dispositivo o después de reinstalar la app

**Requerimiento Padre:** REQ-F2-011 (Copia de seguridad)

**Prioridad:** Baja
**Esfuerzo:** M (2 puntos)

**Dependencias:** HU-034 (Exportar SMS a archivo)

**Criterios de Aceptación:**
- [ ] En la sección "Copia de seguridad" de Configuración, hay un botón "Importar SMS"
- [ ] Al tocar "Importar", se abre el selector de archivos del sistema
- [ ] El importador acepta archivos en formato JSON (generado por HU-034)
- [ ] Al seleccionar un archivo, se valida:
  - Que sea un JSON válido con la estructura esperada
  - Que la versión de la app que lo generó sea compatible
  - Si el archivo no es válido, se muestra un mensaje de error claro
- [ ] Antes de importar, se muestra un resumen:
  - Cantidad de conversaciones a importar
  - Cantidad de mensajes totales
  - Advertencia: "Los mensajes existentes no se eliminarán. Los mensajes duplicados se omitirán."
- [ ] El usuario puede elegir:
  - "Importar todo" (agrega todas las conversaciones del archivo)
  - "Seleccionar conversaciones" (elige cuáles importar)
- [ ] Durante la importación:
  - Se muestra una barra de progreso
  - Los mensajes se insertan en la BD local de Drift
  - Los mensajes duplicados (mismo ID de ContentProvider o mismo contenido+fecha+contacto) se omiten
- [ ] Al completar, se muestra un resumen: "X conversaciones importadas, Y mensajes, Z duplicados omitidos"
- [ ] Si hay errores durante la importación, se muestran pero no interrumpen el proceso
- [ ] Las imágenes MMS incluidas en el archivo (base64) se restauran al directorio de caché

**Capa técnica requerida:**
- **Data:** Método `importFromJson` en `BackupRepository`
- **Domain:** Nuevo `ImportSmsUseCase`
- **Presentation:** Provider para estado de importación, diálogos de progreso

**Notas técnicas:**
- La importación debe ser transaccional: si falla a mitad, hacer rollback para no dejar datos inconsistentes
- Para detectar duplicados: comparar por (phoneNumber, content, date) o por (phoneNumber, content, type)
- Si el archivo contiene imágenes MMS en base64, decodificarlas y almacenarlas en el directorio de la app
- Considerar un límite de tamaño de archivo para importación (ej: 500MB máximo)
- Para archivos muy grandes, ejecutar la importación en un isolate para no bloquear la UI
