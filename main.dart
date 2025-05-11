import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/welcome_screen.dart'; // Ganti dari pages/todo_home_page.dart ke file baru welcome_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(); // menginisialisasi data tgl lokal

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
