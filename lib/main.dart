import 'package:bluetooth_printing/printing/printing_page.dart';
import 'package:flutter/material.dart';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      home: PrintingPage(),
    );
  }
}
