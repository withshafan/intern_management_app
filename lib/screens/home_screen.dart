import 'package:flutter/material.dart';
import 'interns_list_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const InternsListScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNav(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              icons: const [
                Icons.dashboard_rounded,
                Icons.people_alt_rounded,
                Icons.bar_chart_rounded,
                Icons.person_rounded,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
