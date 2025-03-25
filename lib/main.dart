import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habittrack/Database/habit_database.dart';
import 'package:habittrack/pages/home_page.dart';
import 'package:habittrack/theme/light_mode.dart';
import 'package:habittrack/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize database
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();
  
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
    
  }
}
