import 'package:mobile/models/dto/demandeDto.dart';
import 'package:mobile/models/dto/prestataireDto.dart';

class Propositiondto {
  int id;
  String description;
  double tarifProposer;
  DateTime dateDisponible;
  Demandedto demande;
  Prestatairedto prestataire;
  DateTime createdAt;
  DateTime updatedAt;

  Propositiondto({
    required this.id,
    required this.description,
    required this.tarifProposer,
    required this.dateDisponible,
    required this.demande,
    required this.prestataire,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Propositiondto.fromJson(Map<String, dynamic> json) {
    return Propositiondto(
      id: json['id'],
      description: json['description'],
      tarifProposer: json['tarifProposer'],
      dateDisponible: DateTime.parse(json['dateDisponible']),
      demande: Demandedto.fromJson(json['demande']),
      prestataire: Prestatairedto.fromJson(json['prestataire']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'tarifProposer': tarifProposer,
      'dateDisponible': dateDisponible.toIso8601String(),
    };
  }
}