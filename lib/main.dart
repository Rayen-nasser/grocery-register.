import 'package:flutter/material.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Groceries",
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 144, 229, 255),
          brightness: Brightness.dark,
          surface: Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 50, 58, 60),
      ),
      home: const GroceryList(),
    );
  }
}
