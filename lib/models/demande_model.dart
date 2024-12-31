import 'package:mobile/models/demandeur_model.dart';
import 'package:mobile/models/dto/propositionDto.dart';
import 'package:mobile/models/user_model.dart';

class Demande {
  int id;
  String service;
  String description;
  String lieu;
  DateTime dateDisponible;
  Demandeur demandeur;
  // List<Proposition> propositions;
  DateTime createdAt;
  DateTime updatedAt;

  Demande({
    required this.id,
    required this.service,
    required this.description,
    required this.lieu,
    required this.dateDisponible,
    required this.demandeur,
    // required this.propositions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'] ?? 0,
      service: json['service'] ?? "",
      description: json['description'] ?? "",
      lieu: json['lieu'],
      dateDisponible: DateTime.parse(json['dateDisponible'] ?? ""),
      demandeur: Demandeur.fromJson(json['demandeur'] ?? {}),
      // propositions: (json['propositions'] as List)
      //     .map((item) => Proposition.fromJson(item))
      //     .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? ""),
      updatedAt: DateTime.parse(json['updatedAt'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'description': description,
      'lieu': lieu,
      'dateDisponible': dateDisponible.toIso8601String(),
      'demandeur': User.toJson(demandeur),
      // 'propositions': propositions.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}