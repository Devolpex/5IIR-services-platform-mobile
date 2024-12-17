import 'package:mobile/models/user_model.dart';

class Prestataire extends User {
  final List<String> prestataireServices;
  final List<String> propositions;

  Prestataire({
    required int id,
    required String email,
    required String role,
    required String token,
    required bool verified,
    required this.prestataireServices,
    required this.propositions,
  }) : super(id: id, email: email, role: role, token: token, verified: verified);

  factory Prestataire.fromJson(Map<String, dynamic> json) {
    return Prestataire(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
      verified: json['verified'],
      prestataireServices: List<String>.from(json['prestataireServices']),
      propositions: List<String>.from(json['propositions']),
    );
  }

  // @override
  // Map<String, dynamic> toJson() {
  //   final data = super.toJson();
  //   data['prestataireServices'] = prestataireServices;
  //   data['propositions'] = propositions;
  //   return data;
  // }
}