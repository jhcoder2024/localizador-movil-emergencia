# REQ-001: Fase 1 — App SMS Mínima

## Objetivo de Negocio
Convertir "Localizador Móvil de Emergencia" en una app de SMS funcional para que Android la reconozca como app SMS predeterminada, permitiendo que el botón de emergencia envíe SMS automáticamente (sin abrir la app nativa de SMS).

## Problema Actual
- Android 14+ bloquea el envío automático de SMS a menos que la app sea la predeterminada.
- Actualmente se abre la app de SMS nativa con el mensaje pre-llenado (el usuario debe tocar "Enviar" manualmente).
- Esto rompe la experiencia de emergencia: el usuario podría estar incapacitado para enviar.

## Solución Propuesta
Construir una app SMS mínima pero funcional (bandeja de entrada, envío, recepción) que Android reconozca como predeterminada. Una vez establecida como default, el botón de emergencia usará `SmsManager.sendTextMessage()` directamente.

## Requerimientos Funcionales

### REQ-001.1: Base de datos SMS
| Campo | Detalle |
|-------|---------|
| **Descripción** | Crear tablas `conversations` y `sms_messages` en Drift para almacenar SMS localmente |
| **Prioridad** | Must |
| **Dependencias** | Ninguna |
| **Criterios de Éxito** | Las tablas existen, se migra schemaVersion, los DAOs permiten CRUD básico |

### REQ-001.2: Sincronización con ContentProvider de Android
| Campo | Detalle |
|-------|---------|
| **Descripción** | Leer SMS existentes del ContentProvider nativo de Android y sincronizarlos a la BD local |
| **Prioridad** | Must |
| **Dependencias** | REQ-001.1 |
| **Criterios de Éxito** | Al abrir la app, los SMS del sistema aparecen en la BD local. SMS entrantes se reciben en tiempo real vía BroadcastReceiver |

### REQ-001.3: Bandeja de entrada (Inbox)
| Campo | Detalle |
|-------|---------|
| **Descripción** | Pantalla principal con lista de conversaciones agrupadas por remitente |
| **Prioridad** | Must |
| **Dependencias** | REQ-001.2 |
| **Criterios de Éxito** | Muestra remitente, preview del último mensaje, hora, y cantidad de no leídos. Ordenado por fecha descendente |

### REQ-001.4: Visor de conversación y envío
| Campo | Detalle |
|-------|---------|
| **Descripción** | Pantalla de chat con burbujas de mensajes, campo de texto y botón enviar |
| **Prioridad** | Must |
| **Dependencias** | REQ-001.3 |
| **Criterios de Éxito** | Muestra todos los mensajes de una conversación en orden cronológico. Permite escribir y enviar SMS. El envío usa SmsManager directamente |

### REQ-001.5: Emergencia automática
| Campo | Detalle |
|-------|---------|
| **Descripción** | El botón de emergencia envía SMS automáticamente usando SmsManager (sin abrir otra app) |
| **Prioridad** | Must |
| **Dependencias** | REQ-001.4, ser app SMS default |
| **Criterios de Éxito** | Al activar emergencia, los SMS se envían sin intervención del usuario. Si no es app default, guía al usuario a configurarla |

### REQ-001.6: MMS básico (solo lectura)
| Campo | Detalle |
|-------|---------|
| **Descripción** | Soporte para leer y mostrar MMS recibidos (imágenes) en la bandeja de entrada |
| **Prioridad** | Could |
| **Dependencias** | REQ-001.4 |
| **Criterios de Éxito** | Los MMS con imágenes se muestran en la conversación. No se requiere enviar MMS en Fase 1 |

### REQ-001.7: App SMS predeterminada
| Campo | Detalle |
|-------|---------|
| **Descripción** | La app debe poder ser seleccionada como SMS predeterminada en Android |
| **Prioridad** | Must |
| **Dependencias** | REQ-001.1, REQ-001.3 (mínimo funcional para ser default) |
| **Criterios de Éxito** | Android muestra la app en la lista de apps SMS disponibles. Al seleccionarla, los SMS se enrutan a nuestra app |

## Requerimientos No Funcionales

| ID | Descripción | Prioridad |
|----|-------------|-----------|
| RNF-01 | La app debe mantener el rendimiento actual con la BD de SMS (Drift + SQLite) | Must |
| RNF-02 | La sincronización inicial no debe bloquear la UI > 2 segundos | Must |
| RNF-03 | Los SMS deben persistir localmente incluso sin conexión | Must |
| RNF-04 | El botón de emergencia debe seguir funcionando aunque la app esté en segundo plano | Must |
| RNF-05 | La interfaz debe seguir Material Design 3 (consistente con la app actual) | Should |

## Exclusiones (para Fase 2)
- Búsqueda de mensajes
- Modo oscuro
- Emojis/Reacciones
- Envío de MMS
- Programación de mensajes
- Backup/Restore
- Temas personalizados
