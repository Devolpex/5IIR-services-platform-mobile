import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DemandeurPage extends StatelessWidget {
  DemandeurPage({Key? key}) : super(key: key);
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.i("DemandeurPage build");
    return const Scaffold(
      body: Center(
        child: Text("Demandeur Page"),
      ),
    );
  }

}