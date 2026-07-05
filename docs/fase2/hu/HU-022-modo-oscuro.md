# HU-022: Modo oscuro completo con persistencia de preferencia

**Como** usuario
**Quiero** cambiar la app al modo oscuro y que mi preferencia se recuerde al cerrar la app
**Para** reducir la fatiga visual en entornos de poca luz y ahorrar batería en pantallas OLED

**Requerimiento Padre:** REQ-F2-002 (Modo oscuro)

**Prioridad:** Alta
**Esfuerzo:** M (2 puntos)

**Dependencias:** Ninguna (es independiente de la lógica de SMS)

**Criterios de Aceptación:**
- [ ] Se agrega un toggle "Modo oscuro" en la pantalla de configuración
- [ ] El toggle tiene 3 estados: Claro / Oscuro / Seguir sistema
- [ ] La preferencia se persiste en SharedPreferences y se restaura al iniciar la app
- [ ] Al cambiar el toggle, el tema se aplica inmediatamente sin reiniciar la app
- [ ] Todas las pantallas existentes se renderizan correctamente en modo oscuro:
  - Inbox (lista de conversaciones)
  - Pantalla de conversación (burbujas de chat)
  - Pantalla de emergencia
  - Pantalla de configuración
  - Diálogos y modales
- [ ] Los colores de las burbujas de chat se adaptan al modo oscuro:
  - Burbujas recibidas: gris oscuro sobre fondo oscuro
  - Burbujas enviadas: rojo/primario sobre fondo oscuro
- [ ] El texto es legible en ambos modos (contraste suficiente)
- [ ] Las notificaciones respetan el tema del sistema

**Notas técnicas:**
- Usar `ThemeData(brightness: Brightness.dark)` para el tema oscuro
- Aprovechar `ColorScheme.fromSeed` con `brightness: Brightness.dark`
- Usar `MaterialApp(themeMode: themeMode)` con un `ValueNotifier<ThemeMode>` o Provider
- La preferencia se guarda con SharedPreferences bajo la clave `theme_mode`
- Considerar usar `WidgetsBindingObserver` para detectar cambios del tema del sistema
