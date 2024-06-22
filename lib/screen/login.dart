import 'dart:convert';
import 'package:aplikurir/api/api_service.dart';
import 'package:aplikurir/screen/beranda.dart';
import 'package:aplikurir/screen/profil.dart';
import 'package:aplikurir/screen/riwayat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aplikurir/layout_nav_bottom.dart';
import 'package:aplikurir/component/custom_button.dart';
import 'package:aplikurir/component/custom_color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _boolValue = true;
  String? storedEmail;
  String? storedPassword;

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('${ApiService.url}/dataPengantaranLogin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      setState(() {
        storedEmail = _emailController.text;
        storedPassword = _passwordController.text;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenRoute(user: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau password salah!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 650,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  border: const Border(),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: mycolor.color2),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo-icon.png',
                    scale: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Masuk Ke Akun Anda",
                      style: TextStyle(
                        color: mycolor.color3,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email tidak boleh kosong";
                        }
                        return null;
                      },
                      controller: _emailController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: mycolor.color1,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Masukkan Email"),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password tidak boleh kosong";
                        }
                        return null;
                      },
                      controller: _passwordController,
                      obscureText: _boolValue,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: mycolor.color1,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Masukkan Password',
                        suffixIcon: IconButton(
                          icon: Icon(_boolValue
                              ? Icons.visibility
                              : Icons.visibility_off),
                          color: mycolor.color1,
                          onPressed: () {
                            setState(() {
                              _boolValue = !_boolValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 50,
                    width: 350,
                    child: CustomElevatedButton1(
                      onPressed: () {
                        if (_emailController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Email atau password tidak boleh kosong'),
                            ),
                          );
                        } else {
                          _login();
                        }
                      },
                      text: 'Masuk'.toUpperCase(),
                      textStyle: TextStyle(
                        color: mycolor.color2,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: mycolor.color1,
      ),
    );
  }
}

class ScreenRoute extends StatelessWidget {
  final dynamic user;

  const ScreenRoute({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return LayoutNavBottom(
      navigationScreens: [
        BerandaScreen(user: user),
        const RiwayatScreen(),
        ProfilScreen(user: user),
      ],
    );
  }
}
