# Fase 2: SMS Completa — Visión General

## Objetivo
Transformar la app de "SMS Mínima" (Fase 1) en una **app de SMS moderna y completa** con todas las funcionalidades que un usuario espera de su aplicación de mensajería predeterminada, manteniendo el núcleo de emergencia como diferenciador clave.

## Principios Rectores
1. **Experiencia de usuario moderna**: Material Design 3, modo oscuro, animaciones fluidas.
2. **Funcionalidad completa de SMS/MMS**: Leer, escribir, buscar, archivar, programar.
3. **Valor de emergencia primero**: Las funcionalidades que más impactan la seguridad del usuario tienen máxima prioridad.
4. **Iteraciones cortas**: Sprints de 1 semana con ~8 puntos de esfuerzo.

## Funcionalidades Planeadas

| # | Funcionalidad | Descripción | Prioridad |
|---|--------------|-------------|-----------|
| 1 | **Modo oscuro + Material Design 3** | Tema oscuro completo, Material You, Dynamic Colors | Alta |
| 2 | **Búsqueda de mensajes** | Buscar en conversaciones y mensajes | Alta |
| 3 | **Archivar / Eliminar conversaciones** | Gestión de conversaciones (archivar, eliminar, vaciar) | Alta |
| 4 | **Editor de texto enriquecido** | Emojis, formato de texto, adjuntar archivos | Alta |
| 5 | **MMS completo (enviar y recibir)** | Fotos, audio, video por MMS | Alta |
| 6 | **Respuesta rápida desde notificación** | Responder SMS sin abrir la app | Media |
| 7 | **Mensajes programados** | Programar envío de SMS para fecha/hora futura | Media |
| 8 | **Bloqueo de spam** | Bloquear números y filtrar spam | Media |
| 9 | **Copia de seguridad** | Exportar/importar SMS a archivo | Baja |
| 10 | **Widget de escritorio** | Acceso rápido desde el homescreen | Baja |

## Lo que ya existe (Fase 1 completada)
- Bandeja de entrada SMS con lista de conversaciones
- Chat con burbujas (recibidas gris/izquierda, enviadas rojo/derecha)
- Envío de SMS (target SDK 33)
- Sincronización con ContentProvider de Android
- Recepción de SMS en tiempo real (BroadcastReceiver)
- Botón de emergencia con envío automático de ubicación
- Sonido de alarma, notificaciones, foreground service
- Pull-to-refresh, marcado como leídos
- HU-021 (MMS básico solo lectura) — pendiente de Fase 1

## Arquitectura y Tecnologías

### Stack actual (se mantiene)
| Tecnología | Versión | Uso |
|------------|---------|-----|
| Flutter / Dart | 3.x | Framework |
| Drift | ^2.19.0 | SQLite local |
| Provider | ^6.1.2 | State management |
| GetIt + Injectable | ^7.7.0 | DI |
| GoRouter | ^14.2.0 | Navegación |
| Geolocator | ^12.0.0 | GPS |
| Permission Handler | ^11.3.1 | Permisos |

### Nuevas dependencias previstas para Fase 2
| Dependencia | Propósito | Sprint |
|-------------|-----------|--------|
| `flutter_local_notifications` (ya incluida) | Respuesta rápida desde notificación | Sprint 8 |
| `share_plus` | Exportar copia de seguridad | Sprint 10 |
| `file_picker` | Seleccionar archivos para adjuntar MMS | Sprint 7 |
| `image_picker` | Capturar/enviar fotos por MMS | Sprint 7 |
| `emoji_picker_flutter` | Selector de emojis en editor | Sprint 7 |
| `home_widget` | Widget de escritorio Android | Sprint 11 |
| `workmanager` | Tareas en segundo plano (mensajes programados) | Sprint 9 |

## Criterios de Éxito de la Fase 2
- [ ] La app tiene modo oscuro y sigue Material Design 3 con Material You
- [ ] El usuario puede buscar mensajes en todas las conversaciones
- [ ] El usuario puede archivar, eliminar y gestionar conversaciones
- [ ] El usuario puede enviar y recibir MMS (fotos, audio, video)
- [ ] El usuario puede responder SMS desde la notificación
- [ ] El usuario puede programar envíos de SMS
- [ ] El usuario puede bloquear números de spam
- [ ] El usuario puede exportar/importar sus SMS
- [ ] La app tiene un widget de acceso rápido
- [ ] La funcionalidad de emergencia sigue funcionando correctamente
