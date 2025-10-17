import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_entry.dart';
import 'add_food_screen.dart';

class FoodsToTryScreen extends StatelessWidget {
  const FoodsToTryScreen({super.key});

  final List<String> suggestedFoods = const [
    'Avocado',
    'Carrot',
    'Peach',
    'Zucchini',
    'Pear',
    'Sweet Potato',
    'Apple',
    'Broccoli',
  ];

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<FoodEntry>(FoodEntry.boxName);
    final triedFoodNames = box.values.map((f) => f.name.toLowerCase()).toSet();

    final foodsToTry = suggestedFoods
        .where((food) => !triedFoodNames.contains(food.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Foods to Try Next')),
      body: foodsToTry.isEmpty
          ? const Center(child: Text('You have tried all suggested foods!'))
          : ListView.builder(
              itemCount: foodsToTry.length,
              itemBuilder: (context, index) {
                final food = foodsToTry[index];
                return ListTile(
                  title: Text(food),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddFoodScreen(preFillName: food),
                        ),
                      );
                    },
                    child: const Text('Mark as Tried'),
                  ),
                );
              },
            ),
    );
  }
}
