import 'package:flutter/material.dart';
import 'package:sigma_task/view/body.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1087F4),
          secondary: const Color(0xFFE5E5E5),
        ),
      ),
      home: const Body(),
    );
  }
}
