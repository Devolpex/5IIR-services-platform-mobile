import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PrestatairePage extends StatelessWidget {
  PrestatairePage({Key? key}) : super(key: key);
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.i("PrestatairePage build");
    return const Scaffold(
      body: Center(
        child: Text("Prestataire Page"),
      ),
    );
  }

}