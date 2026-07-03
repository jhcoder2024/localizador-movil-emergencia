# HU-011: Mostrar remitente, preview y hora en cada conversación

**Como** usuario
**Quiero** ver el nombre del remitente, una vista previa del último mensaje y la hora en cada conversación
**Para** identificar rápidamente de quién es cada conversación y si requiere atención

**Requerimiento Padre:** REQ-001.3 (Bandeja de entrada)

**Prioridad:** Alta
**Esfuerzo:** 3 puntos

**Dependencias:** HU-009

**Criterios de Aceptación:**
- [ ] Cada elemento de la lista muestra:
  - **Avatar:** Inicial del nombre del contacto o icono por defecto (usar `CircleAvatar`)
  - **Nombre del remitente:** Nombre del contacto (si está en la agenda) o número de teléfono
  - **Preview:** Primeros 50 caracteres del último mensaje (si es MMS, mostrar "📷 Imagen")
  - **Hora:** Formato "h:mm AM/PM" para hoy, "ddd" para esta semana, "dd/MM/aa" para anterior
  - **Badge:** Círculo rojo con número de mensajes no leídos (oculto si es 0)
- [ ] Los nombres de contactos se resuelven desde la agenda del dispositivo (usar `flutter_contacts` o consultar el ContentProvider de contactos)
- [ ] Si el número no está en la agenda, se muestra el número formateado
- [ ] La hora se actualiza en tiempo real (cambia de "hace 2 min" a "hace 1 hora" etc.) — opcional, puede ser solo al abrir la pantalla

**Notas técnicas:**
- Usar `intl` package (ya en pubspec.yaml) para formateo de fechas
- Para resolución de contactos, se puede extender el `ContactoRepository` existente o crear un método que busque por número
- El preview debe truncarse con `...` si excede los 50 caracteres
- Si el mensaje es MMS (tieneMms = true), mostrar "📷 Imagen" como preview
