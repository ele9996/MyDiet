import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/DaysOfTheWeek.dart';
import 'package:untitled/Gym.dart';
import 'package:untitled/app_ui.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyDietApp());
}

class MyDietApp extends StatelessWidget {
  const MyDietApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: uiPink,
      primary: uiPink,
      secondary: uiLilac,
      tertiary: uiMint,
      background: uiBackground,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Diet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: uiBackground,
        textTheme: ThemeData.light().textTheme.copyWith(
              displaySmall: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: uiInk,
              ),
              headlineMedium: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: uiInk,
              ),
              titleLarge: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: uiInk,
              ),
              bodyLarge: const TextStyle(
                color: uiMuted,
                height: 1.45,
              ),
              bodyMedium: const TextStyle(
                color: uiMuted,
                height: 1.4,
              ),
            ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.white,
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(
              color: uiInk,
              fontWeight: states.contains(MaterialState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(MaterialState.selected) ? uiPink : uiMuted,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: uiInk.withOpacity(0.05),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: uiPink,
              width: 1.2,
            ),
          ),
          labelStyle: const TextStyle(
            color: uiMuted,
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      DaysOfTheWeek(),
      Gym(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: uiPink.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationBar(
              height: 72,
              selectedIndex: _currentIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Meals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center),
                  label: 'Training',
                ),
              ],
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
