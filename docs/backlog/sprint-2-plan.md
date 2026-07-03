# Sprint 2: Sincronización con SMS del sistema

## Sprint Goal
Sincronizar los SMS existentes del ContentProvider de Android a la base de datos local y establecer la escucha en tiempo real de SMS entrantes.

## Duración
**Inicio:** Lunes
**Fin:** Viernes (1 semana)
**Capacidad:** ~8 puntos

## Historias de Usuario Seleccionadas

| ID | Título | Esfuerzo | Prioridad |
|----|--------|----------|-----------|
| HU-005 | Leer SMS existentes del ContentProvider de Android | 5 | Alta |
| HU-006 | Sincronizar SMS al abrir la app (primera carga) | 3 | Alta |
| HU-007 | Escuchar SMS entrantes con BroadcastReceiver | 5 | Alta |
| HU-008 | Marcar SMS como leídos | 2 | Media |

**Total:** 15 puntos (excede capacidad — ver notas abajo)

## Dependencias entre HU
```
HU-005 ──► HU-006
  │
  └──► HU-007 ──► HU-008
```

## Orden de Ejecución Recomendado
1. **HU-005** (día 1-3): Implementar el DataSource que lee del ContentProvider vía MethodChannel. Esta es la HU más compleja del sprint.
2. **HU-007** (día 2-4): Actualizar BroadcastReceiver + EventChannel. Se puede empezar una vez que HU-005 tenga el MethodChannel funcionando.
3. **HU-006** (día 4-5): Orquestar la sincronización inicial. Depende de HU-005 completa.
4. **HU-008** (día 5): Marcar como leídos. Depende de HU-007.

## Nota sobre capacidad
Este sprint tiene 15 puntos, casi el doble de la capacidad semanal. **Recomendación:** 
- Si HU-005 resulta muy compleja, mover HU-008 al Sprint 3.
- HU-005 y HU-007 comparten lógica de ContentProvider — se pueden desarrollar en paralelo parcial.
- Considerar extender el sprint a 10 días si es necesario.

## Definition of Done (DoD)
- [ ] Los SMS existentes se importan correctamente desde el ContentProvider
- [ ] La sincronización inicial no bloquea la UI
- [ ] Los SMS entrantes se reciben en tiempo real (app en primer plano)
- [ ] Los SMS entrantes muestran notificación (app en segundo plano)
- [ ] Los mensajes se marcan como leídos al abrir la conversación
- [ ] Tests de integración del flujo de sincronización

## Riesgos
- El ContentProvider de SMS puede variar entre fabricantes (Samsung, Xiaomi, etc.). Probar en múltiples dispositivos.
- El permiso `READ_SMS` es sensible en Android — asegurar que se solicita correctamente.
- El EventChannel puede tener latencia — considerar buffering de eventos.
