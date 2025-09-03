import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light =>
      ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light);

  static ThemeData get dark =>
      ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark);
}
