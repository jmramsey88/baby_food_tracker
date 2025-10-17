// lib/models/food_entry.dart
import 'package:hive/hive.dart';

/// NOTE: we DO NOT use `part 'food_entry.g.dart'` here — adapters are manual.

enum ReactionType { like, neutral, dislike, allergy }

class FoodEntry {
  static const String boxName = 'food_entries';

  String id;
  String name;
  DateTime dateTried;
  ReactionType reaction;
  String? notes;
  List<DateTime> triedDates;

  FoodEntry({
    required this.id,
    required this.name,
    required this.dateTried,
    required this.reaction,
    this.notes,
    List<DateTime>? triedDates,
  }) : triedDates = triedDates ?? [dateTried];

  int get tryCount => triedDates.length;

  void addTry(DateTime date, {ReactionType? newReaction}) {
    triedDates.add(date);
    dateTried = date;
    if (newReaction != null) reaction = newReaction;
  }
}

/// ---------- MANUAL HIVE TYPE ADAPTERS ----------
/// ReactionTypeAdapter stores as a byte (index).
class ReactionTypeAdapter extends TypeAdapter<ReactionType> {
  @override
  final int typeId = 1;

  @override
  ReactionType read(BinaryReader reader) {
    final idx = reader.readByte();
    return ReactionType.values[idx];
  }

  @override
  void write(BinaryWriter writer, ReactionType obj) {
    writer.writeByte(obj.index);
  }
}

/// FoodEntryAdapter serializes the FoodEntry fields.
class FoodEntryAdapter extends TypeAdapter<FoodEntry> {
  @override
  final int typeId = 2;

  @override
  FoodEntry read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final dateMillis = reader.readInt();
    final reactionIdx = reader.readByte();
    final hasNotes = reader.readBool();
    final notes = hasNotes ? reader.readString() : null;

    // read triedDates list
    final triedDatesLen = reader.readInt();
    final triedDates = <DateTime>[];
    for (int i = 0; i < triedDatesLen; i++) {
      final m = reader.readInt();
      triedDates.add(DateTime.fromMillisecondsSinceEpoch(m));
    }

    return FoodEntry(
      id: id,
      name: name,
      dateTried: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      reaction: ReactionType.values[reactionIdx],
      notes: notes,
      triedDates: triedDates,
    );
  }

  @override
  void write(BinaryWriter writer, FoodEntry obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.dateTried.millisecondsSinceEpoch);
    writer.writeByte(obj.reaction.index);
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) writer.writeString(obj.notes!);

    // write triedDates
    writer.writeInt(obj.triedDates.length);
    for (final dt in obj.triedDates) {
      writer.writeInt(dt.millisecondsSinceEpoch);
    }
  }
}
