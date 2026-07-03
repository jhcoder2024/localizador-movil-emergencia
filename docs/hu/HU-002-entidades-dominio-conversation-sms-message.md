# HU-002: Entidades de dominio Conversation y SmsMessage

**Como** desarrollador
**Quiero** crear las entidades de dominio `Conversation` y `SmsMessage` en la capa domain
**Para** mantener la independencia de la capa de datos y seguir Clean Architecture

**Requerimiento Padre:** REQ-001.1 (Base de datos SMS)

**Prioridad:** Alta
**Esfuerzo:** 2 puntos

**Dependencias:** HU-001

**Criterios de Aceptación:**
- [ ] Existe `Conversation` como clase inmutable (usar `equatable` o clase con `==` y `hashCode`) con: `id`, `remitente`, `telefono`, `ultimoMensaje`, `ultimaFecha`, `noLeidos`
- [ ] Existe `SmsMessage` como clase inmutable con: `id`, `conversationId`, `remitente`, `telefono`, `cuerpo`, `fecha`, `tipo` (enum `MensajeType`), `leido`, `tieneMms`
- [ ] Existe el enum `MensajeType` con valores `received` y `sent`
- [ ] Ambas entidades están en `lib/domain/entities/`
- [ ] No contienen referencias a Drift, anotaciones de base de datos ni imports de la capa data

**Notas técnicas:**
- Usar `equatable` para comparación por valor (ya está en pubspec.yaml)
- `Conversation.ultimaFecha` debe ser `DateTime`
- `SmsMessage.fecha` debe ser `DateTime`
- El mapper entre modelo Drift y entidad de dominio se creará en HU-003
