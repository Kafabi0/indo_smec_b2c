import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';

void main() {
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
