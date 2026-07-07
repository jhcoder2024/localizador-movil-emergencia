import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/app/di/presentation_module.dart';
import 'package:localizador_movil_emergencia/presentation/providers/main_provider.dart';
import 'package:localizador_movil_emergencia/presentation/screens/main_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/inbox_screen.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';

class HomeScreen extends StatefulWidget {
  final String? initialTab;
  const HomeScreen({super.key, this.initialTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MainScreen(),
    InboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialTab == 'inbox') {
      _currentIndex = 1;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkWidgetActivation();
    }
  }

  Future<void> _checkWidgetActivation() async {
    try {
      const widgetChannel = MethodChannel('com.example.localizador_movil_emergencia/widget');
      final shouldActivate = await widgetChannel.invokeMethod<bool>('shouldActivateEmergency') ?? false;
      if (shouldActivate) {
        final provider = getIt<MainProvider>();
        if (!provider.estado.activa) {
          provider.solicitarConfirmacion(TipoEmergencia.extraviado);
        }
      }
    } catch (e) {
      debugPrint('[Home] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD32F2F),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Emergencia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mensajes',
          ),
        ],
      ),
    );
  }
}
