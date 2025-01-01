import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/models/dto/propositionDto.dart';
import 'package:mobile/services/auth_service.dart';

import '../utils/keys.dart';

class PropositionService {
  final Logger logger = Logger();
  final Dio dio = Dio();
  final String authToken = AuthService().getAuthToken() ?? "";

  Future<List<Propositiondto>> getPropositionByPrestataireId(String? id) async {
    try {
      final String uri = "$backendUrl/api/proposition/prestataire/$id";
      logger.i("token: $authToken");

      final response = await dio.get(
        uri,
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );

      logger.i("getPropositionByPrestataireId response: ${response.data}");

      final propositions = (response.data as List)
          .map((item) => Propositiondto.fromJson(item))
          .toList();
      return propositions as List<Propositiondto>;
    } catch (e) {
      logger.e("Failed to get proposition by prestataire id: $e");
      throw Exception("Failed to get proposition by prestataire id");
    }
  }

  Future<void> deletePropositionById(int id) async {
    try {
      final String uri = "$backendUrl/api/proposition/$id";
      logger.i("token: $authToken");

      final response = await dio.delete(
        uri,
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );

      logger.i("deletePropositionById response: ${response.data}");
    } catch (e) {
      logger.e("Failed to delete proposition by id: $e");
      throw Exception("Failed to delete proposition by id");
    }
  }

  Future<void> updateProposition(Propositiondto proposition,int id ) async {
    try {
      final String uri = "$backendUrl/api/proposition/${id}";
      logger.i("token: $authToken");

      final response = await dio.put(
        uri,
        data:  jsonEncode(proposition.toJson()),
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );

      logger.i("updateProposition response: ${response.data}");
    } catch (e) {
      logger.e("Failed to update proposition: $e");
      throw Exception("Failed to update proposition");
    }
  }

  // Future<void> addProposition(Proposition proposition) async {
  //   return await _propositionRepository.addProposition(proposition);
  // }


}