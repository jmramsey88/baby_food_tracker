import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/food_entry.dart';
import 'add_food_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<FoodEntry> box;
  final df = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    box = Hive.box<FoodEntry>(FoodEntry.boxName);
  }

  /// Reset all data in the box
  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all saved foods and cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await box.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = box.values.toList().cast<FoodEntry>();
    entries.sort((a, b) => b.dateTried.compareTo(a.dateTried));

    final totalFoods = entries.length;
    final likedFoods =
        entries.where((e) => e.reaction == ReactionType.like).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Food Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatsScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _clearAllData();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset All Data'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryCard('🍽 Foods Tried', totalFoods, const Color(0xFFD7F9EF)),
                _summaryCard('❤️ Foods Liked', likedFoods, const Color(0xFFFFD6E8)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text('No foods added yet! Tap + to add your first.'),
                    )
                  : Column(
                      children: [
                        // Table header
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Food',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Reaction',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '# Tried',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Last Tried',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 40), // space for delete icon
                            ],
                          ),
                        ),
                        const Divider(),
                        // Table rows
                        Expanded(
                          child: ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return _foodRow(entry);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddFoodScreen()),
          );
          setState(() {});
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryCard(String title, int value, Color bg) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _foodRow(FoodEntry entry) {
    Color bgColor;
    String emoji;

    switch (entry.reaction) {
      case ReactionType.like:
        bgColor = Colors.pink.shade50;
        emoji = '❤️';
        break;
      case ReactionType.neutral:
        bgColor = Colors.grey.shade200;
        emoji = '😐';
        break;
      case ReactionType.dislike:
        bgColor = Colors.orange.shade50;
        emoji = '👎';
        break;
      case ReactionType.allergy:
        bgColor = Colors.red.shade50;
        emoji = '⚠️';
        break;
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              entry.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 1, child: Text(emoji, textAlign: TextAlign.center)),
          Expanded(
            flex: 1,
            child: Text(entry.tryCount.toString(), textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(df.format(entry.dateTried)),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete this entry',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry?'),
                  content: Text('Are you sure you want to delete "${entry.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await entry.delete(); // ✅ works now because FoodEntry extends HiveObject
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${entry.name}" deleted')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
