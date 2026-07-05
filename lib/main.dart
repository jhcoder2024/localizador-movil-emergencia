import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localizador_movil_emergencia/app/di/data_module.dart';
import 'package:localizador_movil_emergencia/app/di/domain_module.dart';
import 'package:localizador_movil_emergencia/app/di/presentation_module.dart';
import 'package:localizador_movil_emergencia/presentation/screens/home_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/config_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/permissions_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/splash_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/conversation_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/blocked_numbers_screen.dart';
import 'package:localizador_movil_emergencia/core/theme/app_theme.dart';
import 'package:localizador_movil_emergencia/presentation/services/notification_service.dart';
import 'package:localizador_movil_emergencia/presentation/providers/theme_provider.dart';
import 'package:localizador_movil_emergencia/presentation/services/emergency_background_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initDataModule();
  initDomainModule();
  initPresentationModule();
  await NotificationService.initialize();
  await EmergencyBackgroundService.initialize();
  runApp(const LocalizadorEmergenciaApp());
}

class LocalizadorEmergenciaApp extends StatelessWidget {
  const LocalizadorEmergenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            final tab = state.uri.queryParameters['tab'] ?? 'emergencia';
            return HomeScreen(initialTab: tab == 'inbox' ? 'inbox' : null);
          },
        ),
        GoRoute(
          path: '/inbox',
          redirect: (context, state) => '/?tab=inbox',
        ),
        GoRoute(
          path: '/conversation/:id',
          redirect: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            if (id.isEmpty) return '/';
            return null;
          },
          builder: (context, state) => ConversationScreen(
            conversationId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/config',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ConfigScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
          ),
        ),
        GoRoute(
          path: '/blocked',
          builder: (context, state) => const BlockedNumbersScreen(),
        ),
        GoRoute(
          path: '/permissions',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const PermissionsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    );

    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Localizador Móvil de Emergencia',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('es', 'ES'),
              const Locale('en', 'US'),
            ],
            locale: const Locale('es', 'ES'),
          );
        },
      ),
    );
  }
}
