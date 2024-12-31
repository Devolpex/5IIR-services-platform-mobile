import 'package:dio/dio.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mobile/controllers/auth.dart';
import 'package:mobile/models/demande_model.dart';
import 'package:mobile/models/demandeur_model.dart';
import 'package:mobile/models/proposition_model.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/utils/keys.dart';
import 'package:mobile/utils/top_snackbar.dart';

class DemandeService {
  final Logger logger = Logger();
  final Dio dio = Dio();
  final String authToken = AuthService().getAuthToken() ?? "";
  // // Method to create a new Demande
  // Future<Demande> createDemande(Demande demande) async {
  //   // Implement the logic to create a new Demande
  //   // For example, send a POST request to the backend API
  //   // and return the created Demande object
  // }

  // // Method to update an existing Demande
  // Future<Demande> updateDemande(String id, Demande demande) async {
  //   // Implement the logic to update an existing Demande
  //   // For example, send a PUT request to the backend API
  //   // and return the updated Demande object
  // }

  // // Method to delete an existing Demande
  // Future<void> deleteDemande(String id) async {
  //   // Implement the logic to delete an existing Demande
  //   // For example, send a DELETE request to the backend API
  // }

  // // Method to fetch a Demande by its ID
  // Future<Demande> getDemandeById(String id) async {
  //   // Implement the logic to fetch a Demande by its ID
  //   // For example, send a GET request to the backend API
  //   // and return the fetched Demande object
  // }

  // // Method to fetch a list of all Demandes
  // Future<List<Demande>> getAllDemandes() async {
  //   // Implement the logic to fetch a list of all Demandes
  //   // For example, send a GET request to the backend API
  //   // and return the list of Demande objects
  // }

  // Method to fetch a paginated list of Demandes
  Future<List<Demande>> getDemandesPage() async {
    try {
    final String uri = "$backendUrl/api/demande";
    logger.i("token: $authToken");

    // Send POST request with JSON body
    final response = await dio.get(
      uri,
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      }),
    );
    
    logger.i("Response: ${response.data}");
    if (response.statusCode == 200) {
      // Extract the list of demandes from the 'content' field
      List<dynamic> content = response.data['content'];
      return content.map((item) => Demande.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch demandes: ${response.data}");
    }
  } on DioException catch (e) {
    print("DioException: ${e.message}");
    print("Dio Error Response: ${e.response?.data}");
    onDioError(e); // Your custom error handler
  } catch (e) {
    print("Unknown Error: $e");
    onUnkownError(e); // Your custom error handler
  }
  throw Exception("Unexpected error occurred while fetching demandes");
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