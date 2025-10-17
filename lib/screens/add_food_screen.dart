import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/food_entry.dart';

class AddFoodScreen extends StatefulWidget {
  final String? preFillName;

  const AddFoodScreen({Key? key, this.preFillName}) : super(key: key);

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  ReactionType selectedReaction = ReactionType.like;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.preFillName != null) {
      _nameController.text = widget.preFillName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Food name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a food name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReactionType>(
                value: selectedReaction,
                decoration: const InputDecoration(
                  labelText: 'Reaction',
                  border: OutlineInputBorder(),
                ),
                items: ReactionType.values.map((reaction) {
                  String label;
                  switch (reaction) {
                    case ReactionType.like:
                      label = 'Like ❤️';
                      break;
                    case ReactionType.neutral:
                      label = 'Neutral 😐';
                      break;
                    case ReactionType.dislike:
                      label = 'Dislike 👎';
                      break;
                    case ReactionType.allergy:
                      label = 'Allergy ⚠️';
                      break;
                  }
                  return DropdownMenuItem(
                    value: reaction,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedReaction = value);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${DateFormat('d MMM yyyy').format(selectedDate)}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Save Food'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFood() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final box = Hive.box<FoodEntry>(FoodEntry.boxName);

    FoodEntry? existing;
    try {
      existing = box.values.firstWhere(
        (f) => f.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      existing = null;
    }

    if (existing != null) {
      existing.addTry(selectedDate, newReaction: selectedReaction);
      box.put(existing.id, existing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added another try for $name (${existing.tryCount} total)'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final newEntry = FoodEntry(
        id: DateTime.now().toIso8601String(),
        name: name,
        reaction: selectedReaction,
        dateTried: selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      box.put(newEntry.id, newEntry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $name to foods tried!'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    }

    Navigator.pop(context);
  }
}
