import 'package:isar/isar.dart';


part 'habits.g.dart';

@Collection()
class Habit {
  // habit id
  Id id = Isar.autoIncrement;

  // habit name
  late String name;

  // completed days

  List<DateTime> completed = [

    // DateTime(year, month, day).
    // DateTime(2025, 1, 2),
  ];
}
