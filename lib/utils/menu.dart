import 'package:flutter/material.dart';
import 'package:mobile/utils/colors.dart';

class Menu extends StatelessWidget {
  final List<String> menuItems;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<Widget> pages;

  const Menu({
    Key? key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.pages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            child: DrawerHeader(
              decoration:  BoxDecoration(
                color: primary,
              ),
              margin: EdgeInsets.zero,
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(menuItems[index]),
                  selected: selectedIndex == index,
                  onTap: () {
                    onItemSelected(index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
