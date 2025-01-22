import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_screen.dart';
import 'progress_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final String initialTab;
  
  const MainScreen({
    super.key,
    this.initialTab = 'programs',
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab == 'progress' ? 1 : 0;
  }

  static const List<Widget> _screens = [
    DashboardScreen(),
    ProgressDashboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Update the URL without triggering a full navigation
    if (index == 0) {
      GoRouter.of(context).go('/dashboard');
    } else {
      GoRouter.of(context).go('/progress');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Programs',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}