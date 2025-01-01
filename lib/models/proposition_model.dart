class Proposition {
  String? id;
  String description;
  double tarifProposer;
  DateTime disponibiliteProposer;
  int demandeId;

  Proposition({
    this.id,
    required this.description,
    required this.tarifProposer,
    required this.disponibiliteProposer,
    required this.demandeId,
  });

  factory Proposition.fromJson(Map<String, dynamic> json) {
    return Proposition(
      id: json['id'],
      description: json['description'],
      tarifProposer: json['tarifProposer'],
      disponibiliteProposer: DateTime.parse(json['disponibiliteProposer']),
      demandeId: json['demandeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'tarifProposer': tarifProposer,
      'dateDisponibilite': disponibiliteProposer.toIso8601String(),
      'demandeId': demandeId,
    };
  }
}