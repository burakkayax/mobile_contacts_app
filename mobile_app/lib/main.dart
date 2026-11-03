import 'package:flutter/material.dart';
import 'screens/person_list_screen.dart';

void main() {
  runApp(const PersonManagementApp());
}

class PersonManagementApp extends StatelessWidget {
  const PersonManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehber / Kişi Listesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PersonListScreen(),
    );
  }
}
