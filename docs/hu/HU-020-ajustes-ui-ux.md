# HU-020: Ajustes UI/UX y pulido general

**Como** usuario
**Quiero** que la interfaz de la app de SMS se vea pulida, consistente y profesional
**Para** tener una experiencia de usuario agradable

**Requerimiento Padre:** REQ-001.3, REQ-001.4 (UI/UX general)

**Prioridad:** Media
**Esfuerzo:** 3 puntos

**Dependencias:** HU-016, HU-018

**Criterios de Aceptación:**
- [ ] La navegación entre pantallas es fluida y consistente (usar transiciones de GoRouter existentes)
- [ ] Los estados de carga tienen indicadores (Shimmer o CircularProgressIndicator)
- [ ] Los estados de error tienen mensajes claros y acción de reintentar
- [ ] Los estados vacíos tienen ilustraciones o iconos descriptivos
- [ ] Los textos están en español y son consistentes en toda la app
- [ ] Los tiempos de las fechas usan el locale en español ("hoy", "ayer", "lunes", etc.)
- [ ] La pantalla de conversación tiene un comportamiento correcto del teclado (no cubre el input, scroll automático)
- [ ] El `BottomNavigationBar` tiene iconos y labels claros
- [ ] Se prueba la app en diferentes tamaños de pantalla (teléfono compacto, tablet)
- [ ] Se verifica que no hay fugas de memoria (los Streams de Drift se cancelan al salir de las pantallas)
- [ ] Se agregan tests de widget para las pantallas principales (InboxScreen, ConversationScreen)
- [ ] Se actualiza el `README.md` con las nuevas funcionalidades (opcional)

**Notas técnicas:**
- Usar `intl` con locale `es` para formateo de fechas
- Los `ChangeNotifierProvider` deben hacer `dispose()` correctamente cancelando suscripciones
- Verificar que `ConversationProvider` se cree como factory (no singleton) para que cada conversación tenga su propia instancia
- Agregar `flutter_localizations` en `pubspec.yaml` si no está:
  ```yaml
  flutter_localizations:
    sdk: flutter
  ```
  Y en `MaterialApp.router`:
  ```dart
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [const Locale('es', 'ES')],
  ```
