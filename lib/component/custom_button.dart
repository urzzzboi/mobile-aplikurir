import 'package:aplikurir/component/custom_color.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton1 extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final TextStyle textStyle;
  const CustomElevatedButton1({
    super.key,
    required this.onPressed,
    required this.text,
    this.textStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(mycolor.color1),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}

class CustomElevatedButton2 extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final TextStyle textStyle;
  const CustomElevatedButton2({
    super.key,
    required this.onPressed,
    required this.text,
    this.textStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          side: WidgetStatePropertyAll(BorderSide(
            color: mycolor.color4,
            width: 2,
          ))),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
