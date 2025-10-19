import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/food_entry.dart';
import 'screens/home_screen.dart';
import 'screens/foods_to_try_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ReactionTypeAdapter());
  Hive.registerAdapter(FoodEntryAdapter());

  // Open the box once
  await Hive.openBox<FoodEntry>(FoodEntry.boxName);

  runApp(const BabyFoodTrackerApp());
}

class BabyFoodTrackerApp extends StatelessWidget {
  const BabyFoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Food Tracker',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    FoodsToTryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pinkAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'To Try'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
