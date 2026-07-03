# Product Backlog — Fase 1: App SMS Mínima

## Metodología
- **Duración de Sprint:** 1 semana
- **Capacidad:** ~8 puntos de historia / sprint (1 desarrollador full-stack)
- **Estimación:** Fibonacci (1, 2, 3, 5, 8, 13)
- **Priorización:** MoSCoW (Must > Should > Could > Won't)

---

## Backlog Priorizado

| # | ID | Título | Prioridad | Esfuerzo | Dependencias | Sprint |
|---|----|--------|-----------|----------|--------------|--------|
| 1 | HU-001 | Tablas `conversations` y `sms_messages` en Drift | Alta | 3 | — | Sprint 1 |
| 2 | HU-002 | Entidades de dominio Conversation y SmsMessage | Alta | 2 | HU-001 | Sprint 1 |
| 3 | HU-003 | Repositorio SmsRepository con operaciones de inbox | Alta | 3 | HU-002 | Sprint 1 |
| 4 | HU-004 | Migración de esquema DB (schemaVersion) y DAOs | Alta | 2 | HU-001 | Sprint 1 |
| 5 | HU-005 | Leer SMS existentes del ContentProvider de Android | Alta | 5 | HU-003, HU-004 | Sprint 2 |
| 6 | HU-006 | Sincronizar SMS al abrir la app (primera carga) | Alta | 3 | HU-005 | Sprint 2 |
| 7 | HU-007 | Escuchar SMS entrantes con BroadcastReceiver | Alta | 5 | HU-005 | Sprint 2 |
| 8 | HU-008 | Marcar SMS como leídos | Media | 2 | HU-007 | Sprint 2 |
| 9 | HU-009 | Pantalla de lista de conversaciones (Inbox) | Alta | 5 | HU-006 | Sprint 3 |
| 10 | HU-010 | Ordenar conversaciones por fecha del último mensaje | Alta | 2 | HU-009 | Sprint 3 |
| 11 | HU-011 | Mostrar remitente, preview y hora en cada conversación | Alta | 3 | HU-009 | Sprint 3 |
| 12 | HU-012 | Navegar al tocar una conversación | Alta | 2 | HU-009 | Sprint 3 |
| 13 | HU-013 | Pantalla de conversación con burbujas de chat | Alta | 5 | HU-012 | Sprint 4 |
| 14 | HU-014 | Campo de texto y botón enviar SMS | Alta | 3 | HU-013 | Sprint 4 |
| 15 | HU-015 | Enviar SMS desde la app usando SmsManager | Alta | 5 | HU-014 | Sprint 4 |
| 16 | HU-016 | Actualizar conversación en tiempo real al enviar/recibir | Alta | 3 | HU-015, HU-007 | Sprint 4 |
| 17 | HU-017 | Botón de emergencia integrado en la bandeja (FAB) | Alta | 3 | HU-009 | Sprint 5 |
| 18 | HU-018 | Enviar SMS de emergencia automáticamente (sin abrir otra app) | Alta | 5 | HU-015, HU-017 | Sprint 5 |
| 19 | HU-019 | Solicitar ser app SMS predeterminada + flujo de configuración | Alta | 3 | HU-018 | Sprint 5 |
| 20 | HU-020 | Ajustes UI/UX y pulido general | Media | 3 | HU-016, HU-018 | Sprint 5 |
| 21 | HU-021 | Leer y mostrar MMS básicos (imágenes) en la conversación | Baja | 5 | HU-013 | Sprint 5+ |

## Resumen de Esfuerzo por Sprint

| Sprint | HU | Puntos totales |
|--------|----|----------------|
| Sprint 1 | HU-001, HU-002, HU-003, HU-004 | 10 |
| Sprint 2 | HU-005, HU-006, HU-007, HU-008 | 15 |
| Sprint 3 | HU-009, HU-010, HU-011, HU-012 | 12 |
| Sprint 4 | HU-013, HU-014, HU-015, HU-016 | 16 |
| Sprint 5 | HU-017, HU-018, HU-019, HU-020, HU-021 | 19 |

> **Nota:** Los sprints 2, 4 y 5 exceden la capacidad ideal de 8 pts/semana. Esto es intencional porque algunas HU pueden paralelizarse parcialmente (ej: HU-005 y HU-007 comparten lógica de ContentProvider). Se recomienda re-estimar durante el sprint planning y mover HU de baja prioridad (HU-021) a Fase 2 si es necesario.
