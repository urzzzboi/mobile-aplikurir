import 'package:aplikurir/component/custom_color.dart';
import 'package:flutter/material.dart';

class CustomText1 extends StatelessWidget {
  final String text;
  const CustomText1({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class CustomText2 extends StatelessWidget {
  final String text;
  const CustomText2({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 6,
        child: Text(
          textAlign: TextAlign.right,
          text,
          style: const TextStyle(
            fontSize: 20,
          ),
        ));
  }
}

class CustomContainer extends StatelessWidget {
  final List<Widget> children;
  const CustomContainer({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return Container(
      width: double.infinity,
      color: mycolor.color2,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

class CustomContainer2 extends StatelessWidget {
  final List<Widget> children;
  const CustomContainer2({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return Container(
      width: double.infinity,
      color: mycolor.color2,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
