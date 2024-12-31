import 'package:mobile/models/dto/demandeurDto.dart';

class Demandedto {
  int id;
  String service;
  String description;
  DateTime dateDisponible;
  String lieu;
  Demandeurdto demandeur;
  DateTime createdAt;
  DateTime updatedAt;

  Demandedto({
    required this.id,
    required this.service,
    required this.description,
    required this.dateDisponible,
    required this.lieu,
    required this.demandeur,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Demandedto.fromJson(Map<String, dynamic> json) {
    return Demandedto(
      id: json['id'],
      service: json['service'],
      description: json['description'],
      dateDisponible: DateTime.parse(json['dateDisponible']),
      lieu: json['lieu'],
      demandeur: Demandeurdto.fromJson(json['demandeur']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'description': description,
      'dateDisponible': dateDisponible.toIso8601String(),
      'lieu': lieu,
      'demandeur': demandeur.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}