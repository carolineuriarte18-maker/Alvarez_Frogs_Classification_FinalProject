import 'package:flutter/material.dart';

import 'home/class_selection_page.dart';
import 'home/home_page.dart';
import 'camera/camera_detection_page.dart';
import 'history/history_page.dart';
import 'analytics/dashboard_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ClassSelectionPage(),
    HistoryPage(),
    DashboardPage(),
  ];

  final List<String> _titles = const ['Home', 'Detect', 'History', 'Analytics'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8E6C9),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0.5,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Text('🐸', style: TextStyle(fontSize: 24)),
            onPressed: () {},
            tooltip: 'Frog Identifier',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // If user taps Detect (index 1) open camera directly instead of switching
          if (index == 1) {
            // Open the live camera without selecting a class
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CameraDetectionPage()),
            );
            return;
          }
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Detect',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
