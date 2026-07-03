import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localizador_movil_emergencia/presentation/screens/main_screen.dart';
import 'package:localizador_movil_emergencia/presentation/screens/inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialTab;
  const HomeScreen({super.key, this.initialTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MainScreen(),
    InboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTab == 'inbox') {
      _currentIndex = 1;
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
