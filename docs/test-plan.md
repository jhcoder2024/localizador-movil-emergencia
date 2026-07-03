# Plan de Pruebas — Localizador Móvil de Emergencia

## 1. Resumen Ejecutivo

### Propósito
Este plan define la estrategia de pruebas funcionales, de regresión, rendimiento y permisos para la aplicación **Localizador Móvil de Emergencia**. Su objetivo es garantizar la calidad de los dos modos de funcionamiento (App SMS completa y Botón de emergencia) previo a su publicación o entrega.

### Alcance
**Qué se prueba:**
- Bandeja de entrada de SMS (Inbox)
- Chat / Conversación (envío/recepción de SMS)
- Botón de emergencia (confirmación, envío GPS, sonido, notificaciones, re-envío)
- Configuración (contactos, intervalo, app SMS default)
- Regresión entre módulos
- Rendimiento básico (batería, UI responsiva)
- Permisos (concesión, denegación, reintento)

**Qué NO se prueba:**
- Pruebas de seguridad (penetration testing, cifrado)
- Pruebas de estrés con volumen masivo (>1000 conversaciones)
- Pruebas de compatibilidad con versiones anteriores de Android (<14)
- Pruebas de internacionalización (i18n)
- Pruebas de accesibilidad (WCAG)

### Dispositivos objetivo
| Dispositivo | SO | API | Tipo | Notas |
|---|---|---|---|---|
| Samsung Galaxy A06 | Android 14 | API 34 | Físico — primario | One UI Core, SMS app default NO disponible |
| Xiaomi Redmi Note 12 | Android 14 | API 34 | Físico — secundario | MIUI 14, SMS app default NO disponible |
| Pixel 6a (emulado) | Android 14 | API 34 | Emulador | Referencia Android stock |

---

## 2. Escenarios de Prueba por Módulo

### Módulo: Bandeja de entrada (Inbox)

#### TC-001: Visualizar lista de conversaciones
- **Precondiciones**: App instalada, al menos 3 conversaciones SMS en el dispositivo
- **Pasos**:
  1. Abrir la app
  2. Navegar a la pestaña "Inbox"
  3. Observar la lista de conversaciones
- **Resultado esperado**: Se muestra una lista con todas las conversaciones SMS existentes
- **Resultado obtenido**:

#### TC-002: Ver remitente, preview, hora y badge de no leídos
- **Precondiciones**: Al menos una conversación tiene mensajes no leídos
- **Pasos**:
  1. Abrir la app
  2. Observar cada elemento de la lista de conversaciones
- **Resultado esperado**: Cada conversación muestra: nombre/remitente, preview del último mensaje, hora/timestamp, y badge con cantidad de no leídos (si aplica)
- **Resultado obtenido**:

#### TC-003: Estado vacío (sin conversaciones)
- **Precondiciones**: Dispositivo sin ninguna conversación SMS (simular con dispositivo limpio o borrando datos de la app)
- **Pasos**:
  1. Abrir la app
  2. Navegar a Inbox
- **Resultado esperado**: Se muestra un estado vacío con un mensaje informativo (ej. "No hay conversaciones") y un icono alusivo
- **Resultado obtenido**:

#### TC-004: Orden correcto (último mensaje al tope)
- **Precondiciones**: Múltiples conversaciones con mensajes de diferentes fechas/horas
- **Pasos**:
  1. Abrir la app
  2. Ir a Inbox
  3. Verificar el orden de las conversaciones
- **Resultado esperado**: Las conversaciones están ordenadas por la fecha del último mensaje, mostrando la más reciente al inicio (descendente)
- **Resultado obtenido**:

#### TC-005: Sincronización de SMS al abrir la app
- **Precondiciones**: Se recibieron SMS externamente (desde otra app) mientras la app estaba cerrada
- **Pasos**:
  1. Cerrar la app por completo
  2. Recibir 2 SMS nuevos desde otro dispositivo
  3. Abrir la app
  4. Ir a Inbox
- **Resultado esperado**: Las nuevas conversaciones/mensajes aparecen en la lista después de la sincronización inicial
- **Resultado obtenido**:

#### TC-006: Llegada de nuevo SMS en tiempo real
- **Precondiciones**: App abierta y en primer plano en la pantalla Inbox
- **Pasos**:
  1. Mantener la app abierta en Inbox
  2. Enviar un SMS desde otro dispositivo al número del dispositivo de prueba
  3. Observar la pantalla
- **Resultado esperado**: La nueva conversación o mensaje aparece automáticamente en la lista sin necesidad de recarga manual, dentro de los siguientes segundos
- **Resultado obtenido**:

---

### Módulo: Chat / Conversación

#### TC-007: Abrir conversación desde inbox
- **Precondiciones**: Hay al menos una conversación en Inbox
- **Pasos**:
  1. Ir a Inbox
  2. Tocar sobre una conversación existente
- **Resultado esperado**: Se navega a la pantalla de chat de esa conversación, mostrando el historial de mensajes
- **Resultado obtenido**:

#### TC-008: Visualizar burbujas de chat (recibidas izq, enviadas der)
- **Precondiciones**: La conversación tiene al menos 2 mensajes (1 enviado, 1 recibido)
- **Pasos**:
  1. Abrir una conversación con mensajes mixtos
  2. Observar la disposición de las burbujas
- **Resultado esperado**: Los mensajes recibidos se muestran en burbujas alineadas a la izquierda; los mensajes enviados se muestran en burbujas alineadas a la derecha. Colores diferenciados entre env/rec
- **Resultado obtenido**:

#### TC-009: Enviar mensaje de texto
- **Precondiciones**: App configurada como app SMS predeterminada
- **Pasos**:
  1. Abrir una conversación
  2. Escribir un texto en el campo de entrada
  3. Tocar el botón de enviar
- **Resultado esperado**: El mensaje se envía correctamente y aparece en el historial. El destinatario lo recibe
- **Resultado obtenido**:

#### TC-010: Optimistic update (mensaje aparece inmediatamente)
- **Precondiciones**: App SMS predeterminada, red móvil disponible
- **Pasos**:
  1. Abrir una conversación
  2. Escribir y enviar un mensaje
  3. Observar la burbuja inmediatamente después de tocar enviar
- **Resultado esperado**: El mensaje aparece instantáneamente en la burbuja de chat sin esperar confirmación del operador. Puede mostrar un icono de "enviando" (reloj) que cambia a "enviado" (check) después
- **Resultado obtenido**:

#### TC-011: Marcar como leídos al abrir conversación
- **Precondiciones**: La conversación tiene mensajes no leídos (badge visible en Inbox)
- **Pasos**:
  1. Anotar el badge de no leídos en Inbox para esa conversación
  2. Abrir la conversación
  3. Volver a Inbox
- **Resultado esperado**: El badge de no leídos desaparece. Los mensajes se marcan como leídos
- **Resultado obtenido**:

#### TC-012: Scroll automático al último mensaje
- **Precondiciones**: Conversación con suficientes mensajes como para requerir scroll
- **Pasos**:
  1. Abrir la conversación
  2. Observar la posición inicial del scroll
- **Resultado esperado**: El scroll se posiciona automáticamente al final (último mensaje). Al enviar un nuevo mensaje, el scroll baja automáticamente
- **Resultado obtenido**:

#### TC-013: Estado vacío (sin mensajes en conversación)
- **Precondiciones**: Conversación sin mensajes (nueva) o dispositivo sin historial
- **Pasos**:
  1. Abrir una conversación nueva/vacía
- **Resultado esperado**: Se muestra un estado vacío con un mensaje como "No hay mensajes. Enviá tu primer mensaje"
- **Resultado obtenido**:

---

### Módulo: Botón de emergencia

#### TC-014: Acceso desde InboxScreen (FAB)
- **Precondiciones**: App abierta en Inbox, sin emergencia activa
- **Pasos**:
  1. Ir a la pestaña Inbox
  2. Localizar el FAB (Floating Action Button) de emergencia
  3. Tocar el FAB
- **Resultado esperado**: Se abre el diálogo de confirmación de emergencia
- **Resultado obtenido**:

#### TC-015: Acceso desde BottomNavigationBar
- **Precondiciones**: App abierta en cualquier pestaña, sin emergencia activa
- **Pasos**:
  1. Tocar el ítem de "Emergencia" en la BottomNavigationBar
- **Resultado esperado**: Se abre el diálogo de confirmación de emergencia
- **Resultado obtenido**:

#### TC-016: Diálogo de confirmación de emergencia
- **Precondiciones**: App abierta, sin emergencia activa
- **Pasos**:
  1. Activar el botón de emergencia (TC-014 o TC-015)
  2. Observar el diálogo de confirmación
  3. Tocar "Confirmar" o "Sí, iniciar emergencia"
- **Resultado esperado**: Aparece un diálogo modal preguntando "¿Estás seguro de iniciar una emergencia?" con opciones de tipo de emergencia y botones Confirmar/Cancelar. Al confirmar, se inicia la emergencia
- **Resultado obtenido**:

#### TC-017: Tipos de emergencia (Extraviado, Atrapado, Herido)
- **Precondiciones**: Diálogo de confirmación visible
- **Pasos**:
  1. Observar las opciones de tipo de emergencia en el diálogo
  2. Seleccionar cada tipo (Extraviado, Atrapado, Herido)
  3. Confirmar la emergencia con cada tipo
- **Resultado esperado**: Hay 3 tipos para elegir. El tipo seleccionado se incluye en el mensaje SMS enviado a los contactos. El mensaje varía según el tipo (ej. "Emergencia: [tipo] — Ubicación: ...")
- **Resultado obtenido**:

#### TC-018: Envío automático de SMS (si app SMS default)
- **Precondiciones**: App configurada como app SMS predeterminada, contactos de emergencia configurados
- **Pasos**:
  1. Iniciar una emergencia
  2. Confirmar el tipo
  3. Observar el proceso de envío
- **Resultado esperado**: Los SMS se envían automáticamente a todos los contactos de emergencia sin intervención manual, con la ubicación GPS y el tipo de emergencia
- **Resultado obtenido**:

#### TC-019: Apertura de app de SMS (si NO es app default)
- **Precondiciones**: App NO es la app SMS predeterminada
- **Pasos**:
  1. Iniciar una emergencia
  2. Confirmar
- **Resultado esperado**: Se abre la app de SMS predeterminada del sistema con un mensaje pre-rellenado con la ubicación para que el usuario lo envíe manualmente
- **Resultado obtenido**:

#### TC-020: Contador de tiempo en banner rojo
- **Precondiciones**: Emergencia activa
- **Pasos**:
  1. Iniciar una emergencia
  2. Observar el banner rojo en la parte superior
  3. Verificar que muestra un contador de tiempo transcurrido
- **Resultado esperado**: Un banner rojo persistente muestra el tiempo transcurrido desde que se inició la emergencia (formato MM:SS)
- **Resultado obtenido**:

#### TC-021: Sonido de alarma (cada 5s durante 3 min)
- **Precondiciones**: Emergencia activa, volumen del dispositivo alto
- **Pasos**:
  1. Iniciar emergencia
  2. Escuchar el sonido emitido
  3. Medir el intervalo entre sonidos
- **Resultado esperado**: Suena una alarma intermitente cada 5 segundos durante los primeros 3 minutos de la emergencia. Luego cesa automáticamente
- **Resultado obtenido**:

#### TC-022: Notificación permanente con botones
- **Precondiciones**: Emergencia activa
- **Pasos**:
  1. Iniciar emergencia
  2. Abrir la bandeja de notificaciones del sistema
  3. Observar la notificación
- **Resultado esperado**: Hay una notificación permanente (no descartable) con botones de acción: "Cancelar emergencia" y posiblemente "Silenciar alarma". Tiene alta prioridad y el icono de la app
- **Resultado obtenido**:

#### TC-023: Cancelar emergencia desde notificación
- **Precondiciones**: Emergencia activa con notificación visible
- **Pasos**:
  1. Desplegar la bandeja de notificaciones
  2. Tocar el botón "Cancelar emergencia" en la notificación
- **Resultado esperado**: La emergencia se cancela. El banner rojo desaparece. El sonido se detiene. La notificación se elimina. Se retorna al estado normal
- **Resultado obtenido**:

#### TC-024: Cancelar emergencia desde banner
- **Precondiciones**: Emergencia activa, banner rojo visible en cualquier pantalla
- **Pasos**:
  1. Tocar el banner rojo o el botón de cancelar dentro del banner
  2. Confirmar la cancelación si hay diálogo
- **Resultado esperado**: La emergencia se cancela. El banner desaparece. El sonido se detiene. Se retorna al estado normal
- **Resultado obtenido**:

#### TC-025: Re-envío periódico cada N minutos
- **Precondiciones**: Emergencia activa, intervalo configurado en N minutos (ej. 5 min)
- **Pasos**:
  1. Iniciar emergencia
  2. Esperar que transcurra el intervalo N
  3. Verificar el envío de un nuevo SMS
  4. Repetir para verificar el segundo re-envío
- **Resultado esperado**: Cada N minutos se re-envía automáticamente un SMS con la ubicación actualizada a todos los contactos de emergencia
- **Resultado obtenido**:

#### TC-026: Foreground service mantiene sonido en segundo plano
- **Precondiciones**: Emergencia activa
- **Pasos**:
  1. Iniciar emergencia (debe oírse la alarma)
  2. Presionar Home para enviar la app a segundo plano
  3. Abrir otra app (ej. Chrome, Settings)
- **Resultado esperado**: El sonido de alarma continúa sonando aunque la app esté en segundo plano. La notificación permanece visible
- **Resultado obtenido**:

#### TC-027: GPS optimizado (baja precisión)
- **Precondiciones**: Emergencia activa
- **Pasos**:
  1. Iniciar emergencia y verificar el SMS recibido por el contacto
  2. Observar la precisión de la coordenada en el mensaje
- **Resultado esperado**: La ubicación se obtiene con GPS de baja precisión (aproximadamente <500m), priorizando velocidad y bajo consumo sobre precisión exacta. La coordenada está en formato apropiado para Google Maps
- **Resultado obtenido**:

#### TC-028: Envío a múltiples contactos
- **Precondiciones**: Al menos 3 contactos de emergencia configurados
- **Pasos**:
  1. Iniciar emergencia
  2. Verificar los SMS recibidos en cada uno de los dispositivos de contacto
- **Resultado esperado**: Todos los contactos configurados reciben el SMS de emergencia simultáneamente
- **Resultado obtenido**:

---

### Módulo: Configuración

#### TC-029: Agregar contacto de emergencia
- **Precondiciones**: App abierta en pantalla de Configuración
- **Pasos**:
  1. Ir a Configuración
  2. Tocar "Agregar contacto"
  3. Seleccionar un contacto de la lista de contactos del dispositivo
  4. Confirmar
- **Resultado esperado**: El contacto se agrega a la lista de contactos de emergencia. Aparece en la lista con su nombre y número. Persiste al cerrar y reabrir la app
- **Resultado obtenido**:

#### TC-030: Eliminar contacto
- **Precondiciones**: Al menos un contacto de emergencia configurado
- **Pasos**:
  1. Ir a Configuración
  2. Tocar el icono de eliminar junto a un contacto
  3. Confirmar la eliminación
- **Resultado esperado**: El contacto se elimina de la lista. Desaparece de la UI. Persiste la eliminación al reiniciar la app
- **Resultado obtenido**:

#### TC-031: Configurar intervalo de envío
- **Precondiciones**: App abierta en Configuración
- **Pasos**:
  1. Ir a Configuración
  2. Localizar la opción "Intervalo de re-envío"
  3. Cambiar el valor (ej. de 5 min a 10 min)
  4. Guardar el cambio
- **Resultado esperado**: El intervalo se actualiza. Al iniciar una emergencia, los re-envíos respetan el nuevo intervalo. El valor persiste al cerrar la app
- **Resultado obtenido**:

#### TC-032: Estado app SMS default
- **Precondiciones**: App abierta en Configuración
- **Pasos**:
  1. Ir a Configuración
  2. Observar el indicador de estado de app SMS predeterminada
- **Resultado esperado**: Se muestra claramente si la app es o no la app SMS predeterminada del sistema. El indicador se actualiza si se cambia desde Ajustes del sistema
- **Resultado obtenido**:

#### TC-033: Botón "Establecer como app SMS predeterminada"
- **Precondiciones**: App NO es la app SMS predeterminada
- **Pasos**:
  1. Ir a Configuración
  2. Tocar el botón "Establecer como app SMS predeterminada"
  3. En el diálogo del sistema, seleccionar esta app
- **Resultado esperado**: Se abre el diálogo nativo de Android para cambiar la app SMS predeterminada. Al confirmar, la app pasa a ser la predeterminada. El indicador se actualiza
- **Resultado obtenido**:

---

## 3. Pruebas de Regresión

#### TC-034: La emergencia funciona mientras se usa el chat
- **Precondiciones**: Emergencia activa y conversación SMS abierta
- **Pasos**:
  1. Iniciar una emergencia
  2. Navegar a Inbox
  3. Abrir una conversación
  4. Enviar un mensaje de texto normal
  5. Verificar que el banner rojo sigue visible
  6. Verificar que la alarma sigue sonando
- **Resultado esperado**: La funcionalidad de chat y la emergencia coexisten sin interferencias. El banner rojo persiste. Los SMS de emergencia se siguen enviando
- **Resultado obtenido**:

#### TC-035: Los SMS de emergencia aparecen en la bandeja de entrada
- **Precondiciones**: Emergencia fue activada y se enviaron SMS
- **Pasos**:
  1. Finalizar o cancelar la emergencia
  2. Ir a Inbox
  3. Buscar las conversaciones con los contactos de emergencia
- **Resultado esperado**: Los SMS de emergencia enviados aparecen como mensajes enviados en las conversaciones respectivas dentro de la bandeja de entrada
- **Resultado obtenido**:

#### TC-036: La app no crashea al recibir SMS durante emergencia
- **Precondiciones**: Emergencia activa
- **Pasos**:
  1. Iniciar una emergencia
  2. Recibir un SMS entrante de un contacto no configurado como emergencia
  3. Recibir un SMS entrante de un contacto de emergencia
- **Resultado esperado**: La app no crashea, no se congela ni reinicia. La emergencia continúa activa sin interrupción. El SMS entrante puede verse después en Inbox
- **Resultado obtenido**:

#### TC-037: Navegación entre pestañas no interrumpe emergencia activa
- **Precondiciones**: Emergencia activa
- **Pasos**:
  1. Iniciar emergencia
  2. Navegar a Inbox
  3. Navegar a Configuración
  4. Volver a la pantalla de emergencia
- **Resultado esperado**: La emergencia continúa activa en todo momento. El banner rojo es visible en todas las pantallas. El sonido no se interrumpe al cambiar de pestaña
- **Resultado obtenido**:

---

## 4. Pruebas de Batería / Rendimiento

#### TC-038: Consumo de batería normal en uso de SMS
- **Precondiciones**: App instalada, batería 100%, app en uso activo (enviar/recibir SMS) durante 30 min
- **Pasos**:
  1. Usar la app para enviar y recibir mensajes SMS durante 30 minutos
  2. Registrar el porcentaje de batería consumido mediante el monitor de batería de Android
- **Resultado esperado**: El consumo de batería es comparable al de otras apps de SMS (Google Messages, etc.). No supera el 5% en 30 min de uso activo
- **Resultado obtenido**:

#### TC-039: Consumo durante emergencia activa
- **Precondiciones**: Batería 100%, emergencia activa durante 10 minutos, GPS encendido
- **Pasos**:
  1. Iniciar una emergencia
  2. Mantener la emergencia activa por 10 minutos
  3. Desactivar
  4. Revisar el consumo en Ajustes > Batería
- **Resultado esperado**: El consumo de batería durante la emergencia no es excesivo. El GPS en baja precisión y el foreground service están optimizados para no drenar la batería rápidamente (< 8% en 10 min con GPS + sonido)
- **Resultado obtenido**:

#### TC-040: Sincronización inicial de SMS no bloquea la UI
- **Precondiciones**: Dispositivo con 100+ SMS almacenados, app abierta por primera vez (o datos borrados)
- **Pasos**:
  1. Abrir la app
  2. Observar la pantalla de carga/sincronización
  3. Intentar hacer scroll o tocar elementos durante la sincronización
- **Resultado esperado**: La UI permanece responsiva durante la sincronización inicial. Se puede ver un indicador de carga o progreso. No se bloquea el hilo principal (no ANR)
- **Resultado obtenido**:

---

## 5. Pruebas de Permisos

#### TC-041: Sin permiso SEND_SMS
- **Precondiciones**: Permiso SEND_SMS denegado, contactos configurados
- **Pasos**:
  1. Iniciar una emergencia
  2. Observar el comportamiento
- **Resultado esperado**: La app muestra un mensaje de error o solicita el permiso SEND_SMS. No se envía el SMS hasta que se conceda el permiso. No crashea
- **Resultado obtenido**:

#### TC-042: Sin permiso READ_SMS
- **Precondiciones**: Permiso READ_SMS denegado, hay SMS en el dispositivo
- **Pasos**:
  1. Abrir la app
  2. Ir a Inbox
- **Resultado esperado**: La bandeja de entrada está vacía o la app solicita el permiso. Se muestra un mensaje indicando que se necesita el permiso para leer SMS
- **Resultado obtenido**:

#### TC-043: Sin permiso de ubicación
- **Precondiciones**: Permiso de ubicación denegado, app es app SMS default
- **Pasos**:
  1. Iniciar una emergencia
- **Resultado esperado**: La app solicita el permiso de ubicación. Si se deniega, el SMS se envía sin coordenadas o con un mensaje indicando "Ubicación no disponible". No crashea
- **Resultado obtenido**:

#### TC-044: Sin permiso de notificaciones
- **Precondiciones**: Permiso de notificaciones denegado (Android 13+)
- **Pasos**:
  1. Iniciar una emergencia
  2. Observar si aparece la notificación permanente
- **Resultado esperado**: La app muestra un mensaje o diálogo solicitando permiso de notificaciones al iniciar la emergencia. Sin el permiso, el foreground service puede no mostrar la notificación permanente (comportamiento de Android), pero el sonido se reproduce igual
- **Resultado obtenido**:

#### TC-045: Denegar permiso y reintentar
- **Precondiciones**: Todos los permisos denegados permanentemente (marcar "No volver a preguntar")
- **Pasos**:
  1. Abrir la app
  2. Navegar a una funcionalidad que requiera un permiso (ej. Inbox para READ_SMS)
  3. Observar que la app detecta la denegación permanente
  4. Verificar que redirige a Ajustes del sistema
  5. Conceder el permiso desde Ajustes
  6. Volver a la app
  7. Verificar que la funcionalidad ahora funciona
- **Resultado esperado**: La app detecta correctamente la denegación permanente y guía al usuario a Ajustes del sistema. Al volver con el permiso concedido, la funcionalidad opera correctamente
- **Resultado obtenido**:

---

## Resumen de Casos de Prueba

| Módulo | Cantidad |
|---|---|
| Bandeja de entrada (Inbox) | 6 (TC-001 a TC-006) |
| Chat / Conversación | 7 (TC-007 a TC-013) |
| Botón de emergencia | 15 (TC-014 a TC-028) |
| Configuración | 5 (TC-029 a TC-033) |
| Regresión | 4 (TC-034 a TC-037) |
| Batería / Rendimiento | 3 (TC-038 a TC-040) |
| Permisos | 5 (TC-041 a TC-045) |
| **Total** | **45** |
