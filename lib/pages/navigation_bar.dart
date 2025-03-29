import 'package:eferme_app/pages/calculator_page.dart';
import 'package:eferme_app/pages/diseaseDetection/disease_detection_page.dart';
import 'package:eferme_app/pages/homepage.dart';
import 'package:eferme_app/pages/settings/settings_page.dart';
import 'package:eferme_app/pages/weather/weather_page.dart';
import 'package:eferme_app/widgets/auth_guard.dart';
import 'package:flutter/material.dart';

class Navigationbar extends StatefulWidget {
  const Navigationbar({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _pages = <Widget>[
    AuthGuard(child: HomePage()),
    AuthGuard(child: CalculatorPage()),
    AuthGuard(child: DiseaseDetectionPage()),
    AuthGuard(child: WeatherPage()),
    AuthGuard(child: SettingsPage()),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFc2c7b8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey.shade900, 
        showSelectedLabels: true, 
        showUnselectedLabels: false,
        onTap: _onDestinationSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Disease Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}