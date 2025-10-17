import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
//import 'pages/grafik_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkySense',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardPage(), // default buka dashboard
    );
  }
}
