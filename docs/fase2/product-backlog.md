# Product Backlog — Fase 2: SMS Completa

## Metodología
- **Duración de Sprint:** 1 semana
- **Capacidad:** ~8 puntos de historia / sprint (1 desarrollador full-stack)
- **Estimación:** T-Shirt Sizing (S=1, M=2, L=3, XL=5) — mapeado a puntos de historia
- **Priorización:** MoSCoW (Must > Should > Could > Won't)

## Backlog Priorizado

| # | ID | Título | Prioridad | Esfuerzo | Dependencias | Sprint |
|---|----|--------|-----------|----------|--------------|--------|
| 1 | HU-021 | Leer y mostrar MMS básicos (imágenes) en la conversación | Alta (arrastrada) | L (3) | HU-013 | Sprint 6 |
| 2 | HU-022 | Modo oscuro completo con persistencia de preferencia | Alta | M (2) | — | Sprint 6 |
| 3 | HU-023 | Migración a Material Design 3 con Material You | Alta | L (3) | HU-022 | Sprint 6 |
| 4 | HU-024 | Búsqueda de conversaciones y mensajes | Alta | XL (5) | HU-009, HU-013 | Sprint 7 |
| 5 | HU-025 | Archivar y desarchivar conversaciones | Alta | M (2) | HU-009 | Sprint 7 |
| 6 | HU-026 | Eliminar conversaciones con confirmación | Alta | S (1) | HU-025 | Sprint 7 |
| 7 | HU-027 | Editor de texto enriquecido con emojis | Alta | L (3) | HU-014 | Sprint 8 |
| 8 | HU-028 | Enviar MMS con fotos desde la galería/cámara | Alta | XL (5) | HU-021, HU-027 | Sprint 8 |
| 9 | HU-029 | Recibir y visualizar MMS de audio y video | Alta | L (3) | HU-021 | Sprint 8 |
| 10 | HU-030 | Respuesta rápida desde la notificación | Media | L (3) | HU-007, HU-013 | Sprint 9 |
| 11 | HU-031 | Mensajes programados (crear, listar, cancelar) | Media | XL (5) | HU-015 | Sprint 9 |
| 12 | HU-032 | Bloqueo de números spam | Media | M (2) | HU-009 | Sprint 10 |
| 13 | HU-033 | Reportar y gestionar conversaciones bloqueadas | Media | M (2) | HU-032 | Sprint 10 |
| 14 | HU-034 | Copia de seguridad: exportar SMS a archivo | Baja | M (2) | HU-003 | Sprint 10 |
| 15 | HU-035 | Copia de seguridad: importar SMS desde archivo | Baja | M (2) | HU-034 | Sprint 10 |
| 16 | HU-036 | Widget de escritorio: conversaciones recientes | Baja | L (3) | HU-009 | Sprint 11 |
| 17 | HU-037 | Widget de escritorio: acceso rápido a emergencia | Baja | M (2) | HU-036 | Sprint 11 |

## Resumen de Esfuerzo por Sprint

| Sprint | HU incluidas | Puntos totales |
|--------|-------------|----------------|
| Sprint 6 | HU-021, HU-022, HU-023 | 8 |
| Sprint 7 | HU-024, HU-025, HU-026 | 8 |
| Sprint 8 | HU-027, HU-028, HU-029 | 11* |
| Sprint 9 | HU-030, HU-031 | 8 |
| Sprint 10 | HU-032, HU-033, HU-034, HU-035 | 8 |
| Sprint 11 | HU-036, HU-037 | 5 |

> **\*Sprint 8 excede los 8 pts ideales (11 pts).** Esto es intencional porque HU-028 (MMS con fotos) y HU-029 (MMS audio/video) comparten la misma infraestructura de ContentProvider MMS. Se recomienda re-estimar durante el sprint planning y, si es necesario, mover HU-029 al Sprint 9.

## Mapa de Dependencias

```
HU-021 (MMS lectura) ──► HU-028 (MMS envío fotos)
                      └──► HU-029 (MMS audio/video)

HU-022 (Modo oscuro) ──► HU-023 (MD3)

HU-009 (Inbox Fase 1) ──► HU-024 (Búsqueda)
                        └──► HU-025 (Archivar)
                              └──► HU-026 (Eliminar)

HU-014 (Campo texto F1) ──► HU-027 (Editor enriquecido)

HU-007 (Notif Fase 1) ──► HU-030 (Respuesta rápida)
HU-013 (Chat Fase 1)  ──► HU-030

HU-015 (Enviar SMS F1) ──► HU-031 (Programados)

HU-009 (Inbox Fase 1) ──► HU-032 (Bloqueo)
HU-032 ──► HU-033 (Gestionar bloqueos)

HU-003 (Repo SMS F1) ──► HU-034 (Exportar)
HU-034 ──► HU-035 (Importar)

HU-009 (Inbox Fase 1) ──► HU-036 (Widget)
HU-036 ──► HU-037 (Widget emergencia)
```

## Leyenda de Esfuerzo

| Talla | Puntos | Descripción |
|-------|--------|-------------|
| S (Small) | 1 | Cambio trivial, pocas líneas |
| M (Medium) | 2 | Funcionalidad acotada, 1-2 archivos |
| L (Large) | 3 | Funcionalidad completa, varios archivos |
| XL (Extra Large) | 5 | Funcionalidad compleja, múltiples capas |
