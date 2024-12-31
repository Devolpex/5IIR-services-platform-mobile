import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

import 'package:mobile/models/demande_model.dart';


import 'package:mobile/services/auth_service.dart';
import 'package:mobile/utils/keys.dart';
import 'package:mobile/utils/top_snackbar.dart';

class DemandeService {
  final Logger logger = Logger();
  final Dio dio = Dio();
  final String authToken = AuthService().getAuthToken() ?? "";
  final AuthService _authService = AuthService();

  /// Gestion des erreurs Dio
  void _handleDioError(DioError e) {
    if (e.response != null) {
      logger.e("Erreur Serveur [${e.response?.statusCode}] : ${e.response?.data}");
    } else {
      logger.e("Erreur Réseau : ${e.message}");
    }
  }

  /// Récupérer la liste des offres
  Future<List<dynamic>> getOffres() async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.get(
        "$backendUrl/api/offres/list",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data is List) {
        logger.i("Offres récupérées avec succès.");
        return response.data;
      } else {
        logger.e("Erreur lors de la récupération des offres : ${response.data}");
        return [];
      }
    } on DioError catch (e) {
      _handleDioError(e);
      return [];
    } catch (e) {
      logger.e("Erreur inconnue lors de la récupération des offres : $e");
      return [];
    }
  }

  /// Approuver une offre
  Future<void> approveOffer(int offerId, BuildContext context) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) {
        throw Exception("Token non trouvé.");
      }

      // Configuration des en-têtes HTTP
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      // URL pour l'approbation de l'offre
      final orderUrl = "$backendUrl/api/order/offer/confirm/$offerId";

      // Appel PATCH pour approuver l'offre
      final response = await dio.patch(
        orderUrl,
        options: Options(headers: headers),
      );

      // Gestion de la réponse
      if (response.statusCode == 200) {
        print("Offre approuvée avec succès : ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offre approuvée avec succès.")),
        );
      } else {
        print("Erreur lors de l'approbation de l'offre : ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'approbation de l'offre.")),
        );
      }
    } catch (e) {
      // Gestion des erreurs
      print("Erreur lors de l'approbation de l'offre : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau ou serveur.")),
      );
    }
  }



  /// Récupérer les détails d'une offre
  Future<Map<String, dynamic>> getOfferDetails(int id) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.get(
        "$backendUrl/api/offres/$id",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        logger.i("Détails de l'offre récupérés avec succès.");
        return response.data;
      } else {
        logger.e("Erreur lors de la récupération des détails de l'offre : ${response.data}");
        return {};
      }
    } on DioError catch (e) {
      _handleDioError(e);
      return {};
    } catch (e) {
      logger.e("Erreur inconnue lors de la récupération des détails de l'offre : $e");
      return {};
    }
  }

  /// Créer une nouvelle demande
  Future<void> createDemande(Map<String, dynamic> demandeData) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.post(
        "$backendUrl/api/demande",
        data: jsonEncode(demandeData),
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 201) {
        logger.i("Demande créée avec succès.");
      } else {
        logger.e("Erreur lors de la création de la demande : ${response.data}");
      }
    } on DioError catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      logger.e("Erreur inconnue lors de la création de la demande : $e");
      rethrow;
    }
  }


  /// Mettre à jour une demande existante
  Future<void> updateDemande(int id, Map<String, dynamic> demandeData) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.put(
        "$backendUrl/api/demande/$id",
        data: jsonEncode(demandeData),
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        logger.i("Demande mise à jour avec succès.");
      } else {
        logger.e("Erreur lors de la mise à jour de la demande : ${response.data}");
      }
    } on DioError catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      logger.e("Erreur inconnue lors de la mise à jour de la demande : $e");
      rethrow;
    }
  }

  /// Récupérer les demandes de l'utilisateur
  Future<List<dynamic>> getUserDemandes() async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.get(
        "$backendUrl/api/demande/mes-demandes",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        logger.i("Demandes récupérées avec succès.");
        return response.data;
      } else {
        logger.e("Erreur lors de la récupération des demandes : ${response.data}");
        return [];
      }
    } on DioError catch (e) {
      _handleDioError(e);
      return [];
    } catch (e) {
      logger.e("Erreur inconnue lors de la récupération des demandes : $e");
      return [];
    }
  }
  /// Supprimer une demande existante
  Future<void> deleteDemande(int id) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.delete(
        "$backendUrl/api/demande/$id",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 204) {
        logger.i("Demande supprimée avec succès.");
      } else {
        logger.e("Erreur lors de la suppression de la demande : ${response.data}");
      }
    } on DioError catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      logger.e("Erreur inconnue lors de la suppression de la demande : $e");
      rethrow;
    }
  }


  Future<List<dynamic>> getApprovedDemandes() async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await dio.get(
        "$backendUrl/api/order/demande/confirmed/my-demandes",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        logger.i("Demandes approuvées récupérées avec succès.");
        return response.data;
      } else {
        logger.e("Erreur lors de la récupération des demandes approuvées : ${response.data}");
        return [];
      }
    } on DioError catch (e) {
      _handleDioError(e);
      return [];
    } catch (e) {
      logger.e("Erreur inconnue lors de la récupération des demandes approuvées : $e");
      return [];
    }
  }

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
