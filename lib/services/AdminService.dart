import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'auth_service.dart';

class AdminService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  final Logger logger = Logger();
  final String baseUrl = dotenv.env['BACKEND_URL'] ?? "";

  AdminService() {
    if (baseUrl.isEmpty) {
      logger.e("BACKEND_URL non configuré dans le fichier .env.");
      throw Exception("BACKEND_URL non configuré.");
    }
  }

  /// Gestion des erreurs Dio
  void _handleDioError(DioError e) {
    if (e.response != null) {
      logger.e("Erreur Serveur [${e.response?.statusCode}] : ${e.response?.data}");
    } else {
      logger.e("Erreur Réseau : ${e.message}");
    }
  }

  /// Récupérer les demandes
  Future<List<dynamic>> getDemandes() async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await _dio.get(
        "$baseUrl/api/demande/list",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data is List) {
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

  /// Récupérer les offres
  Future<List<dynamic>> getOffres() async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await _dio.get(
        "$baseUrl/api/offres/list",
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

  /// Supprimer une demande
  Future<void> deleteDemande(int id) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await _dio.delete(
        "$baseUrl/api/demande/$id",
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

  /// Supprimer une offre
  Future<void> deleteOffre(int id) async {
    try {
      final token = _authService.getAuthToken();
      if (token == null) throw Exception("Token non trouvé.");

      final response = await _dio.delete(
        "$baseUrl/api/offres/$id",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 204) {
        logger.i("Offre supprimée avec succès.");
      } else {
        logger.e("Erreur lors de la suppression de l'offre : ${response.data}");
      }
    } on DioError catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      logger.e("Erreur inconnue lors de la suppression de l'offre : $e");
      rethrow;
    }
  }
}
