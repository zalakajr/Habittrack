import 'package:flutter/cupertino.dart';
import 'package:habittrack/models/app_settings.dart';
import 'package:habittrack/models/habits.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  // Setup

  // Init Database

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // save first date at app strutup (for heatmap)

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup (for heatmap)

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }
  // CraudeOperations

  // List of habits

  final List<Habit> currentHabits = [];

  // Create - add a new habit
  Future<void> addHabit(String habitName) async {
    // Create new habit
    final newHabit = Habit()..name = habitName;

    // save to database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // re-read from the database

    readHabits();
  }

  Future<void> readHabits() async {
    // fetch all habits from db
    List<Habit> fetchHabits = await isar.habits.where().findAll();
    // give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchHabits);

    // update ui
    notifyListeners();
  }

  // Read- read saved habits from db

  // update - check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the specific habit

    final habit = await isar.habits.get(id);

    // update completed status

    if (habit != null) {
      await isar.writeTxn(() async {
        // if habits is completed add the current date to the completeDays list
        if (isCompleted && habit.completed.contains(DateTime.now())) {
          final today = DateTime.now();

          // add the current date if it's note already in the list
          habit.completed.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));
        }

        // if habit is not completed remove the current date from the list

        else {
          // remove the current date if the habit is markded as not isCompleted
          habit.completed.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }

        // save the updated habits back to the db

        await isar.habits.put(habit);
      });
    }
  }

  // update - edit habit name

  Future<void> updateHabitName(int id, String newName) async {
    // update habit name
    final habit = await isar.habits.get(id);

    if (habit != null) {
      //update name

      await isar.writeTxn(() async {
        habit.name = newName;

        // save updated habit back to the database

        await isar.habits.put(habit);
      });
    }

    // re-read from the db

    readHabits();
  }

  // Delete - delete habit

  Future<void> deletHabit(int id) async {
    // perform the delte

    await isar.writeTxn( () async {
      await isar.habits.delete(id);
    });

    // re-read from the db

    readHabits();
  }
}
