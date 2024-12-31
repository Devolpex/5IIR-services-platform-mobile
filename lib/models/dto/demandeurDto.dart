class Demandeurdto {
  int id;
  String nom;

  Demandeurdto({
    required this.id,
    required this.nom,
  });

  factory Demandeurdto.fromJson(Map<String, dynamic> json) {
    return Demandeurdto(
      id: json['id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}