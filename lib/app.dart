import 'package:flutter/material.dart';
import 'package:wise_splash_screen/app_data.dart';

class App extends StatelessWidget {
  const App({
    required this.data,
    super.key,
  });

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            'assets/images/built_with_flutter.png',
            height: 70,
          ),
        ),
      ),
    );
  }
}
