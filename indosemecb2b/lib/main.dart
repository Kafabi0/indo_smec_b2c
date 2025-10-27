import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndoSemec b2c',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
