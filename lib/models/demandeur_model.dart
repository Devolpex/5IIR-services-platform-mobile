import 'package:mobile/models/user_model.dart';

class Demandeur extends User {
  final String name;

  Demandeur({
    required int id,
    required String email,
    required String role,
    required String token,
    required bool verified,
    required this.name,
  }) : super(id: id, email: email, role: role, token: token, verified: verified);

  factory Demandeur.fromJson(Map<String, dynamic> json) {
    return Demandeur(
      id: json['id'] ?? 0,
      email: json['email'] ?? "",
      role: json['role'] ?? "",
      token: json['token'] ?? "",
      verified: json['verified'] ?? false,
      name: json['name'] ?? "",
    );
  }

  // @override
  // Map<String, dynamic> toJson() {
  //   final data = super.toJson();
  //   data['name'] = name;
  //   return data;
  // }
}