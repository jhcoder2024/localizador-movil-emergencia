import 'package:flutter/material.dart';
import 'package:localizador_movil_emergencia/presentation/screens/main_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/config_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/permissions_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String main = '/';
  static const String config = '/config';
  static const String permissions = '/permissions';

  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      main: (context) => const MainScreen(),
      config: (context) => const ConfigScreen(),
      permissions: (context) => const PermissionsScreen(),
    };
  }
}
