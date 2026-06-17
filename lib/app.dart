import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'ui/day/day_screen.dart';

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const DayScreen(),
    );
  }
}
