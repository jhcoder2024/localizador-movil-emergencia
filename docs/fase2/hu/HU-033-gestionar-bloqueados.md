# HU-033: Reportar y gestionar conversaciones bloqueadas

**Como** usuario
**Quiero** ver los mensajes bloqueados y gestionar mi lista de números bloqueados
**Para** tener control total sobre quién puede contactarme y revisar si algún mensaje bloqueado era importante

**Requerimiento Padre:** REQ-F2-010 (Bloqueo de spam)

**Prioridad:** Media
**Esfuerzo:** M (2 puntos)

**Dependencias:** HU-032 (Bloqueo de números spam)

**Criterios de Aceptación:**
- [ ] Existe una pantalla "Spam y bloqueados" accesible desde Configuración o menú de navegación
- [ ] La pantalla tiene dos secciones/pestañas:
  - **"Bloqueados"**: Lista de números bloqueados con opción de desbloquear
  - **"Spam"**: Mensajes recibidos de números bloqueados (si se optó por almacenarlos)
- [ ] En la sección de bloqueados, cada item muestra:
  - Número de teléfono
  - Fecha en que se bloqueó
  - Botón "Desbloquear"
- [ ] En la sección de spam (si aplica), cada item muestra:
  - Número y nombre (si está en contactos)
  - Preview del mensaje
  - Fecha y hora
  - Opciones: "No es spam" (mover a inbox) y "Mantener en spam"
- [ ] Al desbloquear un número, se muestra confirmación y se actualiza la lista
- [ ] Al marcar "No es spam", el mensaje se mueve a la bandeja de entrada normal
- [ ] Hay un contador en el menú que indica cuántos mensajes de spam hay (ej: "Spam (3)")
- [ ] Opción "Vaciar spam" que elimina todos los mensajes de spam con confirmación
- [ ] Opción "Bloquear contacto" desde la pantalla de spam (si el número no está bloqueado aún)

**Capa técnica requerida:**
- **Data:** Métodos en `BlockedNumberDao` para listar, desbloquear, contar
- **Presentation:** Nueva pantalla `SpamScreen` con pestañas, provider para estado de spam

**Notas técnicas:**
- Si se opta por almacenar mensajes bloqueados, crear tabla `spam_messages` con misma estructura que `sms_messages`
- Alternativa más simple: no almacenar mensajes bloqueados (solo descartarlos) — reduce complejidad
- La decisión de almacenar o descartar spam debe ser configurable por el usuario
- Considerar integración con la base de datos de spam de Android (API 26+ tiene `TelecomManager` para identificar spam)
