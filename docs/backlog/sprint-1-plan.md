# Sprint 1: Base de datos y dominio SMS

## Sprint Goal
Establecer la base de datos local y las entidades de dominio necesarias para almacenar y gestionar SMS, sentando las bases para toda la Fase 1.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-001 | Tablas `conversations` y `sms_messages` en Drift | 3 | Alta |
| HU-002 | Entidades de dominio Conversation y SmsMessage | 2 | Alta |
| HU-003 | Repositorio SmsInboxRepository con operaciones de inbox | 3 | Alta |
| HU-004 | Migración de esquema DB (schemaVersion) y DAOs | 2 | Alta |

**Total:** 10 puntos (ligeramente por encima de la capacidad — se ajustará en planning)

## Dependencias entre HU
```
HU-001 ──► HU-002 ──► HU-003
  │                      │
  └──────────► HU-004 ───┘
```

## Orden de Ejecución Recomendado
1. **HU-001** (día 1-2): Tablas Drift + regenerar `.g.dart`
2. **HU-004** (día 2-3): Migración schema + DAOs (se puede hacer en paralelo parcial con HU-002)
3. **HU-002** (día 2-3): Entidades de dominio
4. **HU-003** (día 4-5): Interfaz + implementación + mappers + tests

## Definition of Done (DoD)
- [ ] Código compilado sin errores
- [ ] `build_runner` ejecutado sin errores
- [ ] Tests unitarios pasando (mínimo: repositorio mockeado)
- [ ] Migración de BD probada (v1 → v2 sin pérdida de datos)
- [ ] Código revisado y mergeado a main

## Riesgos
- La migración de schema de Drift puede ser compleja si hay datos existentes. Tener un backup de la BD antes de probar.
- Los archivos `.g.dart` pueden dar errores si las tablas no están bien definidas.
