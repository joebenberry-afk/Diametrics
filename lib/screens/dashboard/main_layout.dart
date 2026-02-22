import 'package:flutter/material.dart';
import '../../theme.dart';
import 'home_screen.dart';

// Placeholder imports for phase 4
import 'emergency_screen.dart';
import 'statistics_screen.dart';
import 'add_food_screen.dart';
import 'reminders_screen.dart';
import 'circle_management_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = -1; // -1 means home screen is active

  final List<Widget> _screens = [
    const EmergencyScreen(),
    const StatisticsScreen(),
    const AddFoodScreen(),
    const RemindersScreen(),
    const CircleManagementScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goHome() {
    setState(() {
      _selectedIndex = -1;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = -1;
            });
          },
          child: const Text('Diametrics'),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: 32,
            ), // Using standard icon for now
            onPressed: () {
              // TODO: Account settings
            },
            tooltip: 'Account',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: SeniorTheme.primaryCyan),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: _goHome,
            ),
          ],
        ),
      ),
      body: _selectedIndex == -1
          ? const HomeScreen()
          : _screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: SeniorTheme.primaryCyan,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  0,
                  Icons.shield,
                  'Emergency',
                  Icons.shield_outlined,
                ),
                _buildNavItem(
                  1,
                  Icons.bar_chart,
                  'Statistics',
                  Icons.bar_chart,
                ),
                _buildNavItem(
                  2,
                  Icons.restaurant,
                  'Add food',
                  Icons.restaurant,
                ),
                _buildNavItem(
                  3,
                  Icons.check_box,
                  'Reminders',
                  Icons.check_box_outlined,
                ),
                _buildNavItem(4, Icons.group, 'Circle', Icons.group_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconData,
    String label,
    IconData unselectedIcon,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? iconData : unselectedIcon,
              color: SeniorTheme.surfaceBlack,
              size: 28,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: SeniorTheme.bodyStyle.copyWith(
              fontSize: 10,
              color: SeniorTheme.surfaceBlack,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
