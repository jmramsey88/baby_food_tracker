import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_entry.dart';

class StatsScreen extends StatelessWidget {
  StatsScreen({Key? key}) : super(key: key);

  // Access Hive box via a getter
  Box<FoodEntry> get box => Hive.box<FoodEntry>(FoodEntry.boxName);

  @override
  Widget build(BuildContext context) {
    final entries = box.values.toList().cast<FoodEntry>();

    final likes = entries.where((e) => e.reaction == ReactionType.like).length;
    final neutrals = entries.where((e) => e.reaction == ReactionType.neutral).length;
    final dislikes = entries.where((e) => e.reaction == ReactionType.dislike).length;
    final allergies = entries.where((e) => e.reaction == ReactionType.allergy).length;

    return Scaffold(
      appBar: AppBar(title: Text('Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard('❤️ Likes', likes, Colors.pink.shade100),
                _statCard('😐 Neutral', neutrals, Colors.grey.shade200),
                _statCard('👎 Dislike', dislikes, Colors.orange.shade100),
                _statCard('⚠️ Allergy', allergies, Colors.red.shade100),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Total foods recorded: ${entries.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int value, Color bg) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
