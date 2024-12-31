class Prestatairedto {
  int id;
  String email;

  Prestatairedto({
    required this.id,
    required this.email,
  });

  factory Prestatairedto.fromJson(Map<String, dynamic> json) {
    return Prestatairedto(
      id: json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}