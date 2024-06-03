class Emplacement {
  String idEmplacement;
  String entrepot;
  String etagere;
  String rayon;

  Emplacement({
    required this.idEmplacement,
    required this.entrepot,
    required this.etagere,
    required this.rayon,
  });

  Map<String, dynamic> toMap() {
    return {
      'idEmplacement': idEmplacement,
      'entrepot': entrepot,
      'etagere': etagere,
      'rayon': rayon,
    };
  }

  factory Emplacement.fromMap(Map<String, dynamic> map) {
    return Emplacement(
      idEmplacement: map['idEmplacement'],
      entrepot: map['entrepot'],
      etagere: map['etagere'],
      rayon: map['rayon'],
    );
  }
}
