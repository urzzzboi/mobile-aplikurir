import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/screen/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return GestureDetector(
      child: Scaffold(
        backgroundColor: mycolor.color2,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 15,
              child: Image.asset(
                'assets/images/logo.png',
                scale: 2,
              ),
            ),
            Expanded(
              child: Text(
                'Ketuk layar untuk melanjutkan',
                style: TextStyle(
                  color: mycolor.color1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Route tampilanLogin = MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
        Navigator.push(context, tampilanLogin);
      },
    );
  }
}
