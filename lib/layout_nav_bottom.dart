import 'package:flutter/material.dart';
import 'package:aplikurir/component/custom_color.dart';

class LayoutNavBottom extends StatefulWidget {
  const LayoutNavBottom({super.key, required this.navigationScreens});

  final List<Widget> navigationScreens;

  @override
  State<LayoutNavBottom> createState() => _LayoutNavBottomState();
}

class _LayoutNavBottomState extends State<LayoutNavBottom> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return Scaffold(
      body: widget.navigationScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mycolor.color1,
        items: <BottomNavigationBarItem>[
          _buildNavItem(
            icon: Icons.home,
            index: 0,
            selectedIndex: _selectedIndex,
            mycolor: mycolor,
          ),
          _buildNavItem(
            icon: Icons.menu_book,
            index: 1,
            selectedIndex: _selectedIndex,
            mycolor: mycolor,
          ),
          _buildNavItem(
            icon: Icons.person,
            index: 2,
            selectedIndex: _selectedIndex,
            mycolor: mycolor,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedFontSize: 10,
        selectedItemColor: mycolor.color2,
        unselectedItemColor: mycolor.color2,
        onTap: _onItemTapped,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required int index,
    required int selectedIndex,
    required CustomStyle mycolor,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              icon,
              size: 30,
            ),
          ),
          if (selectedIndex == index)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mycolor.color2,
                ),
                child: Icon(
                  icon,
                  color: mycolor.color1,
                  size: 30,
                ),
              ),
            ),
        ],
      ),
      label: ' ',
    );
  }
}
