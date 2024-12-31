class Proposition {
  String id;
  String description;
  double tarifProposer;
  DateTime disponibiliteProposer;

  Proposition({
    required this.id,
    required this.description,
    required this.tarifProposer,
    required this.disponibiliteProposer,
  });

  factory Proposition.fromJson(Map<String, dynamic> json) {
    return Proposition(
      id: json['id'],
      description: json['description'],
      tarifProposer: json['tarifProposer'],
      disponibiliteProposer: DateTime.parse(json['disponibiliteProposer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'tarifProposer': tarifProposer,
      'disponibiliteProposer': disponibiliteProposer.toIso8601String(),
    };
  }
}