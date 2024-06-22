import 'package:aplikurir/component/custom_color.dart';
import 'package:flutter/material.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        shadowColor: mycolor.color3,
        elevation: 3,
        backgroundColor: mycolor.color1,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(
            "Riwayat",
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: mycolor.color2),
          ),
        ),
        excludeHeaderSemantics: false,
      ),
      body: const Center(
        child: Text("Riwayat"),
      ),
    );
  }
}
