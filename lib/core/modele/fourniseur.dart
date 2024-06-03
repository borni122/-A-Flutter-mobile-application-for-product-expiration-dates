class Fournisseur {
  String idFournisseur;
  String nomFournisseur;
  String telephone;

  Fournisseur({
    required this.idFournisseur,
    required this.nomFournisseur,
    required this.telephone,
  });

  Map<String, dynamic> toMap() {
    return {
      'idFournisseur': idFournisseur,
      'nomFournisseur': nomFournisseur,
      'téléphone': telephone,
    };
  }

  factory Fournisseur.fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      idFournisseur: map['idFournisseur'],
      nomFournisseur: map['nomFournisseur'],
      telephone: map['telephone'],
    );
  }
}
