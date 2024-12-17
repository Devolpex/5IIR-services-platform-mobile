import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mobile/controllers/auth.dart';
import 'package:mobile/screens/authentication/welcome.dart';
import 'package:mobile/screens/layout_page.dart';
import 'package:mobile/services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final auth = Get.put(AuthState());
  Logger logger = Logger();

  final _hiveDb = AuthService();

  _init() {
    final account = _hiveDb.getAuth();
    if (account != null) {
      auth.isSignedIn.value = true;
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.i("AuthWrapper build");
    return Obx(
      () => auth.isSignedIn.value ? LayoutPage() : const WelcomeScreen(),
    );
  }
}
