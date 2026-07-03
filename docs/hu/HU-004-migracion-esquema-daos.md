# HU-004: Migración de esquema DB (schemaVersion) y DAOs

**Como** desarrollador
**Quiero** incrementar el `schemaVersion` de la base de datos e implementar la migración
**Para** que las tablas existentes (`contactos`, `config`) y las nuevas (`conversations`, `sms_messages`) coexistan sin pérdida de datos

**Requerimiento Padre:** REQ-001.1 (Base de datos SMS)

**Prioridad:** Alta
**Esfuerzo:** 2 puntos

**Dependencias:** HU-001

**Criterios de Aceptación:**
- [ ] `schemaVersion` se incrementa de 1 a 2 en `AppDatabase`
- [ ] Existe un `MigrationStrategy` con `onUpgrade` que crea las tablas nuevas sin borrar las existentes
- [ ] Los datos existentes en `contactos` y `config` se conservan después de la migración
- [ ] Se genera el archivo de schema con `dart run drift_dev schema dump lib/data/datasources/local/app_database.dart`
- [ ] Se genera el archivo de schema version 1 (existente) y version 2 (nuevo) en `lib/data/datasources/local/schemas/`
- [ ] Se genera el test de migración con `dart run drift_dev schema generate drift_schema_test.dart` (opcional pero recomendado)
- [ ] La app inicia correctamente en dispositivos con BD existente (migración desde v1) y en dispositivos nuevos (creación desde cero)

**Notas técnicas:**
- Drift requiere archivos de schema para migraciones seguras
- Comandos útiles:
  ```bash
  # Generar schema de la versión actual
  dart run drift_dev schema dump lib/data/datasources/local/app_database.dart lib/data/datasources/local/schemas/
  
  # Generar test de migración
  dart run drift_dev schema generate drift_schema_test.dart --from-migration-path lib/data/datasources/local/schemas/
  ```
- La migración debe ser `CREATE TABLE IF NOT EXISTS` para las tablas nuevas
