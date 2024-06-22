import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/screen/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return MaterialApp(
      theme: ThemeData(
          primaryColor: mycolor.color2,
          appBarTheme: AppBarTheme(backgroundColor: mycolor.color1)),
      home: const SplashScreen(),
    );
  }
}
