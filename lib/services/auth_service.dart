
import 'package:logger/logger.dart';
import 'package:mobile/models/user_model.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/utils/boxes.dart';
import 'package:mobile/utils/keys.dart';
import 'package:mobile/utils/top_snackbar.dart';

class AuthService {  
  Box authBox = Hive.box(Boxes.authBox);
  final dio = Dio();
  Logger logger = Logger();

  User? getAuth() {
    try {
      // Fetch the stored accounts from the authBox
      final data = authBox.keys.map((key) {
        final value = authBox.get(key);
        // print("getAuth value: $value");
        if (value == null) {
          throw Exception("Unexpected error occurred during login");
        }
        // Return the account
      final accountData = value["account"];
      if (accountData is Map) {
        return User.fromJson(Map<String, dynamic>.from(accountData));
      } else {
        throw Exception("Invalid account data");
      }
    }).toList();
      // Return the most recent (or single) account
      return data.isNotEmpty ? data.last : null;
    } catch (e) {
    // Log the error for debugging purposes
    print("getAuth error: $e");
    return null;
  }
}

  String? getAuthToken() {
    try {
      final data = authBox.keys.map((key) {
        final value = authBox.get(key);
        if (value == null) return null;

        DateTime expiredAt = DateTime.parse(value["expiredAt"]);
        if (!expiredAt.isAfter(DateTime.now())) {
          removeAuth();
          throw Exception("Token expired");
        }
        return value["authToken"];
      }).toList();
      return data.reversed.toList().whereType<String>().single;
    } catch (e) {
      print("getAuthToken error: $e");
      return null;
    }
  }

  Future<bool> addAuth(User account) async {
    try {
      await authBox.add(
        {
          "email": account.email,
          "authToken": account.token,
          "role": account.role,
        },
      );
      return true;
    } catch (e) {
      print("Sign in failed: ");
      return false;
    }
  }

  Future<bool> removeAuth() async {
    try {
      await authBox.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  //Sign in to account using Backend API
  Future<bool> signIn(String email, String password, Function(bool, String?) onAuthCompleted) async {
  try {
    if (email.isEmpty || password.isEmpty) {
      onAuthCompleted(false, "Email or password cannot be empty.");
      return false;
    }

    final userMap = await login(email, password);

    final account = User.fromJson(userMap);

    final success = await addAuth(account);
    if (success) {
      onAuthCompleted(true, null);
      return true;
    } else {
      onAuthCompleted(false, "Failed to store authentication data.");
      return false;
    }
  } catch (e, stacktrace) {
    // Log the full exception and stacktrace for easier debugging
    print("Error during sign-in: $e");
    print("Stacktrace: $stacktrace");
    onAuthCompleted(false, "An unknown error occurred: $e");
    return false;
  }
}


// Login to account using backend API
Future<Map<String, dynamic>> login(String email, String pwd) async {
  try {
    final String uri = "$backendUrl/api/auth/login";

    print("Sending request to: $uri");
    print("Request body: ${jsonEncode({'email': email, 'password': pwd})}");

    // Send POST request with JSON body
    final response = await dio.post(
      uri,
      options: Options(headers: {
        'Content-Type': 'application/json',
      }),
      data: jsonEncode({'email': email, 'password': pwd}),
    );
    
    logger.i("Response: ${response.data}");
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Failed to login: ${response.data}");
    }
  } on DioException catch (e) {
    print("DioException: ${e.message}");
    print("Dio Error Response: ${e.response?.data}");
    onDioError(e); // Your custom error handler
  } catch (e) {
    print("Unknown Error: $e");
    onUnkownError(e); // Your custom error handler
  }
  throw Exception("Unexpected error occurred during login");
}

  void onDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      try {
        showMessage(
          message: data["message"],
          title: data["data"] ?? "Something went wrong",
          type: MessageType.error,
        );
      } catch (e) {
        showMessage(
          message:
              "Something went wrong | Unknown error occured, try again later or contact admin",
          title: "Internal Server Error",
          type: MessageType.error,
        );
      }
    } else {
      String msg = e.message ?? "Unkown error";
      if (DioExceptionType.receiveTimeout == e.type ||
          DioExceptionType.sendTimeout == e.type) {
        msg =
            "Server is not reachable. Please verify your internet connection and try again";
      } else
      // if (e.type != DioErrorType.unknown)
      {
        msg = "Problem connecting to the server. Please try again.";
      }
      showMessage(
        message: msg,
        title: "Something went wrong",
        type: MessageType.error,
      );
    }
  }

  void onUnkownError(Object e) {
    showMessage(
      message: e.toString(),
      title: "Something went wrong",
      type: MessageType.error,
    );
  }

  void onSuccess({required String title, required String message}) {
    showMessage(
      message: message,
      title: title,
      type: MessageType.success,
    );
  }
}
