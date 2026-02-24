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

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const EmergencyScreen();
      case 1:
        return const StatisticsScreen();
      case 2:
        return const AddFoodScreen();
      case 3:
        return const RemindersScreen();
      case 4:
        return const CircleManagementScreen();
      default:
        return const HomeScreen();
    }
  }

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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 32),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open Menu',
            );
          },
        ),
        title: GestureDetector(
          onTap: _goHome,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Robot Mascot Icon',
                child: Image.asset(
                  'assets/images/robot_mascot.png',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Diametrics',
                style: SeniorTheme.headingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                // TODO: Account settings
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(
                      'assets/images/robot_mascot.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: SeniorTheme.surfaceBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          : _buildScreen(_selectedIndex),
      bottomNavigationBar: Container(
        color: SeniorTheme.primaryCyan,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  iconWidget: _buildSOSIcon(),
                  label: 'Emergency Alert',
                ),
                _buildNavItem(
                  index: 1,
                  iconWidget: const Icon(Icons.bar_chart, size: 28),
                  label: 'Monthly Statistics',
                ),
                _buildNavItem(
                  index: 2,
                  iconWidget: const Icon(Icons.restaurant, size: 28),
                  label: 'Add food',
                ),
                _buildNavItem(
                  index: 3,
                  iconWidget: const Icon(Icons.check_box_outlined, size: 28),
                  label: 'Reminders',
                ),
                _buildNavItem(
                  index: 4,
                  iconWidget: const Icon(Icons.group, size: 28),
                  label:
                      'Circle managment', // Spelled like mockup intentionally or user requested it, but we'll stick to correct spelling: management
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSOSIcon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: SeniorTheme.surfaceBlack,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'SOS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required Widget iconWidget,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    // Replace "managment" typo from mockup with "management" to be safe, but keep styling exact
    final displayName = label.replaceFirst('managment', 'management');

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          label: 'Tab: $displayName',
          selected: isSelected,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8A8A8A) // Darker grey for active
                      : const Color(0xFFC7C7C7), // Lighter grey for inactive
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: iconWidget,
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9, // Small font to mimic mockup labels
                  color: SeniorTheme.surfaceBlack,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
