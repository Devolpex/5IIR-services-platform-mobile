import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LayoutPage extends StatelessWidget {
  LayoutPage({Key? key}) : super(key: key);
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.i("LayoutPage build");
    return const Scaffold(
      body: Center(
        child: Text("Layout Page"),
      ),
    );
  }

}