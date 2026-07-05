# HU-023: Migración a Material Design 3 con Material You

**Como** usuario
**Quiero** que la app tenga una interfaz moderna con Material Design 3 y colores dinámicos (Material You)
**Para** tener una experiencia visual coherente con el resto del sistema Android

**Requerimiento Padre:** REQ-F2-003 (Material Design 3)

**Prioridad:** Alta
**Esfuerzo:** L (3 puntos)

**Dependencias:** HU-022 (Modo oscuro)

**Criterios de Aceptación:**
- [ ] La app usa `useMaterial3: true` (ya está configurado, verificar coherencia)
- [ ] Los componentes visuales siguen las guías de Material Design 3:
  - `NavigationBar` (Bottom Navigation) con estilo M3
  - `FloatingActionButton` con esquinas redondeadas M3
  - `Card` con elevación y bordes M3
  - `AppBar` con estilo M3 (centralizado, sin elevación)
  - `Dialog` con esquinas redondeadas M3
  - `Switch`, `Slider`, `Checkbox` con estilo M3
- [ ] Los colores dinámicos (Material You) se aplican automáticamente en Android 12+:
  - Usar `ColorScheme.fromSeed(seedColor: ...)` o `dynamicColor: true`
  - El color primario se obtiene del sistema si está disponible
  - En versiones anteriores a Android 12, se usa el color rojo corporativo como fallback
- [ ] Las superficies usan las variantes de color M3:
  - `surfaceContainerHighest` para tarjetas y listas
  - `surfaceVariant` para fondos secundarios
  - `outline` para bordes y separadores
- [ ] La tipografía sigue la escala de tipos M3 (Display, Headline, Title, Body, Label)
- [ ] Los iconos usan el estilo M3 (filled/outlined según el contexto)
- [ ] Las animaciones y transiciones siguen el sistema de movimiento M3
- [ ] La pantalla de conversación se rediseña con componentes M3:
  - Input bar con `InputChip` para adjuntos
  - Burbujas con forma M3 (bordes más redondeados)
- [ ] La pantalla de emergencia mantiene su identidad visual (rojos intensos) pero con componentes M3

**Notas técnicas:**
- Ya existe `useMaterial3: true` en `app_theme.dart` — verificar que todos los componentes lo soporten
- Para Material You: usar `ColorScheme.fromSeed` con `brightness` dinámico
- En Android 12+: `WidgetsFlutterBinding.ensureInitialized()` + `PlatformDispatcher.instance.platformBrightness`
- Revisar `ThemeData` actual y migrar propiedades obsoletas de M2 a M3
- Componentes clave a migrar:
  - `AppBar` → usar `centerTitle: true` (ya está), quitar `elevation`
  - `Card` → usar `CardThemeData` con M3 defaults
  - `FloatingActionButton` → usar `FAB` grande (extended) para acciones principales
  - `NavigationBar` → reemplazar `BottomNavigationBar` si existe
