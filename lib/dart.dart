import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
/*
class Fournisseur {
  final String id;
  final String nomFournisseur;

  Fournisseur({required this.id, required this.nomFournisseur});

  static Fournisseur fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      id: map['id'] ?? '',
      nomFournisseur: map['nomFournisseur'] ?? '',
    );
  }
}

class Categorie {
  final String id;
  final String nomDeCategorie;

  Categorie({required this.id, required this.nomDeCategorie});
}

class Lot {
  String idLot;
  int quantite;
  Timestamp dateExpiration;
  DocumentReference produitRef;
  DocumentReference fournisseurRef;
  String qrImageUrl;
  String type;

  Lot({
    required this.idLot,
    required this.quantite,
    required this.dateExpiration,
    required this.produitRef,
    required this.fournisseurRef,
    required this.qrImageUrl,
    required this.type,
  });

  factory Lot.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return Lot(
      idLot: data['idLot'] ?? '',
      quantite: data['quantite'] ?? 0,
      dateExpiration: data['dateExpiration'] ?? Timestamp.now(),
      produitRef: data['produitRef'] ?? FirebaseFirestore.instance.collection('produits').doc(),
      fournisseurRef: data['fournisseurRef'] ?? FirebaseFirestore.instance.collection('fournisseurs').doc(),
      qrImageUrl: data['qrImageUrl'] ?? '',
      type: data['type'] ?? '',
    );
  }

  String formattedExpirationDate() {
    return DateFormat('dd/MM/yyyy').format(dateExpiration.toDate());
  }

  Map<String, dynamic> toMap() {
    return {
      'idLot': idLot,
      'quantite': quantite,
      'dateExpiration': dateExpiration,
      'produitRef': produitRef,
      'fournisseurRef': fournisseurRef,
      'qrImageUrl': qrImageUrl,
      'type': type,
    };
  }
}

class Marque {
  final String id;
  final String nomDeMarque;

  Marque({required this.id, required this.nomDeMarque});
}

class Produit {
  String idProduit;
  String nomDeProduit;
  String image;
  DocumentReference categorieRef;
  DocumentReference marqueRef;

  Produit({
    required this.idProduit,
    required this.nomDeProduit,
    required this.image,
    required this.categorieRef,
    required this.marqueRef,
  });

  static Produit fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return Produit(
      idProduit: snapshot.id,
      nomDeProduit: data['nomDeProduit'],
      image: data['image'],
      categorieRef: data['categorieRef'],
      marqueRef: data['marqueRef'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProduit': idProduit,
      'nomDeProduit': nomDeProduit,
      'image': image,
      'categorieRef': categorieRef,
      'marqueRef': marqueRef,
    };
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 25), // Ajout d'un espace supplémentaire
              LotExpirationDistribution(),
              SizedBox(height: 25), // Ajout d'un espace supplémentaire
              MostStockedProducts(),
              SizedBox(height: 25), // Ajout d'un espace supplémentaire
            ],
          ),
        ),
      ),
    );
  }
}

double calculatePercentage(int value, int total) {
  if (total == 0) return 0;
  return (value / total) * 100;
}

class DetailedChartPage extends StatelessWidget {
  final String title;
  final String description;

  DetailedChartPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: DetailedPieChart(), // Add the detailed pie chart here
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('lots').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No Data Available'));
        }

        var lots = snapshot.data!.docs.map((doc) => Lot.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();

        Map<String, int> categoryCount = {};
        List<Future<void>> futures = [];

        for (var lot in lots) {
          futures.add(lot.produitRef.get().then((productSnapshot) {
            var produit = Produit.fromFirestore(productSnapshot as DocumentSnapshot<Map<String, dynamic>>);
            return produit.categorieRef.get().then((categorySnapshot) {
              var category = Categorie(
                id: categorySnapshot.id,
                nomDeCategorie: categorySnapshot['nomDeCategorie'],
              );
              if (!categoryCount.containsKey(category.nomDeCategorie)) {
                categoryCount[category.nomDeCategorie] = 0;
              }
              categoryCount[category.nomDeCategorie] = categoryCount[category.nomDeCategorie]! + lot.quantite;
            });
          }));
        }

        return FutureBuilder(
          future: Future.wait(futures),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<PieChartSectionData> sections = categoryCount.entries.map((entry) {
              final double percentage = calculatePercentage(entry.value, lots.length);
              return PieChartSectionData(
                value: entry.value.toDouble(),
                title: '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                showTitle: true,
              );
            }).toList();

            return PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    // Optional: Handle touch interactions
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class LotExpirationDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Distribution des Dates d\'Expiration des Lots',
              description: 'Cette analyse montre la répartition des lots selon leur date d\'expiration.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.orangeAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Distribution des Dates d'Expiration des Lots",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('lots').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No Data Available'));
                  }

                  var lots = snapshot.data!.docs.map((doc) => Lot.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();

                  Map<String, int> expirationDistribution = {
                    '0-30 jours': 0,
                    '31-60 jours': 0,
                    '61-90 jours': 0,
                    '90+ jours': 0,
                  };

                  var now = DateTime.now();

                  for (var lot in lots) {
                    var daysToExpiration = lot.dateExpiration.toDate().difference(now).inDays;

                    if (daysToExpiration <= 30) {
                      expirationDistribution['0-30 jours'] = expirationDistribution['0-30 jours']! + 1;
                    } else if (daysToExpiration <= 60) {
                      expirationDistribution['31-60 jours'] = expirationDistribution['31-60 jours']! + 1;
                    } else if (daysToExpiration <= 90) {
                      expirationDistribution['61-90 jours'] = expirationDistribution['61-90 jours']! + 1;
                    } else {
                      expirationDistribution['90+ jours'] = expirationDistribution['90+ jours']! + 1;
                    }
                  }

                  var totalLots = lots.length;

                  List<BarChartGroupData> barGroups = expirationDistribution.entries.map((entry) {
                    var percentage = (entry.value / totalLots * 100).toStringAsFixed(1) + '%';
                    return BarChartGroupData(
                      x: expirationDistribution.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(), // Mise à jour de 'y' à 'toY'
                          color: Colors.lightBlue,
                          width: 20,
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList();

                  return Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text(
                                      expirationDistribution.keys.toList()[value.toInt()],
                                    );
                                  },
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipPadding: EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  var percentage = (rod.toY / totalLots * 100).toStringAsFixed(1) + '%';
                                  return BarTooltipItem(
                                    '${expirationDistribution.keys.toList()[group.x.toInt()]}\n$percentage',
                                    TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),

                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Cette analyse montre la répartition des lots selon leur date d'expiration.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MostStockedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Produits les Plus Stockés',
              description: 'Cette analyse montre les produits ayant les stocks les plus élevés.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.lightGreenAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Produits les Plus Stockés",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('lots').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No Data Available'));
                  }

                  var lots = snapshot.data!.docs.map((doc) => Lot.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();

                  Map<String, int> productStockCount = {};
                  List<Future<void>> futures = [];

                  for (var lot in lots) {
                    futures.add(lot.produitRef.get().then((productSnapshot) {
                      var produit = Produit.fromFirestore(productSnapshot as DocumentSnapshot<Map<String, dynamic>>);
                      if (!productStockCount.containsKey(produit.nomDeProduit)) {
                        productStockCount[produit.nomDeProduit] = 0;
                      }
                      productStockCount[produit.nomDeProduit] = productStockCount[produit.nomDeProduit]! + lot.quantite;
                    }));
                  }

                  return FutureBuilder(
                    future: Future.wait(futures),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var sortedProducts = productStockCount.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      List<BarChartGroupData> barGroups = sortedProducts.map((entry) {
                        return BarChartGroupData(
                          x: sortedProducts.indexOf(entry),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Colors.lightBlue,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList();

                      return Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: barGroups,
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        return Text(
                                          sortedProducts[value.toInt()].key.split('').join('\n'),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Cette analyse montre les produits ayant les stocks les plus élevés.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Fournisseur {
  final String id;
  final String nomFournisseur;

  Fournisseur({required this.id, required this.nomFournisseur});

  static Fournisseur fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      id: map['id'] ?? '',
      nomFournisseur: map['nomFournisseur'] ?? '',
    );
  }
}

class Categorie {
  final String id;
  final String nomDeCategorie;

  Categorie({required this.id, required this.nomDeCategorie});
}

class Lot {
  String idLot;
  int quantite;
  Timestamp dateExpiration;
  DocumentReference produitRef;
  DocumentReference fournisseurRef;
  String qrImageUrl;
  String type;

  Lot({
    required this.idLot,
    required this.quantite,
    required this.dateExpiration,
    required this.produitRef,
    required this.fournisseurRef,
    required this.qrImageUrl,
    required this.type,
  });

  factory Lot.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return Lot(
      idLot: data['idLot'] ?? '',
      quantite: data['quantite'] ?? 0,
      dateExpiration: data['dateExpiration'] ?? Timestamp.now(),
      produitRef: data['produitRef'] ?? FirebaseFirestore.instance.collection('produits').doc(),
      fournisseurRef: data['fournisseurRef'] ?? FirebaseFirestore.instance.collection('fournisseurs').doc(),
      qrImageUrl: data['qrImageUrl'] ?? '',
      type: data['type'] ?? '',
    );
  }

  String formattedExpirationDate() {
    return DateFormat('dd/MM/yyyy').format(dateExpiration.toDate());
  }

  Map<String, dynamic> toMap() {
    return {
      'idLot': idLot,
      'quantite': quantite,
      'dateExpiration': dateExpiration,
      'produitRef': produitRef,
      'fournisseurRef': fournisseurRef,
      'qrImageUrl': qrImageUrl,
      'type': type,
    };
  }
}

class Marque {
  final String id;
  final String nomDeMarque;

  Marque({required this.id, required this.nomDeMarque});
}

class Produit {
  String idProduit;
  String nomDeProduit;
  String image;
  DocumentReference categorieRef;
  DocumentReference marqueRef;

  Produit({
    required this.idProduit,
    required this.nomDeProduit,
    required this.image,
    required this.categorieRef,
    required this.marqueRef,
  });

  static Produit fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return Produit(
      idProduit: snapshot.id,
      nomDeProduit: data['nomDeProduit'],
      image: data['image'],
      categorieRef: data['categorieRef'],
      marqueRef: data['marqueRef'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProduit': idProduit,
      'nomDeProduit': nomDeProduit,
      'image': image,
      'categorieRef': categorieRef,
      'marqueRef': marqueRef,
    };
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 25), // Ajout d'un espace supplémentaire
              LotExpirationDistribution(),
              SizedBox(height: 25), // Ajout d'un espace supplémentaire
              MostStockedProducts(),
              SizedBox(height: 25), // Ajout d'un espace supplémentaire
            ],
          ),
        ),
      ),
    );
  }
}


double calculatePercentage(int value, int total) {
  if (total == 0) return 0;
  return (value / total) * 100;
}

class DetailedChartPage extends StatelessWidget {
  final String title;
  final String description;

  DetailedChartPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: DetailedPieChart(), // Add the detailed pie chart here
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('lots').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No Data Available'));
        }

        var lots = snapshot.data!.docs.map((doc) => Lot.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();

        Map<String, int> categoryCount = {};
        List<Future<void>> futures = [];

        for (var lot in lots) {
          futures.add(lot.produitRef.get().then((productSnapshot) {
            var produit = Produit.fromFirestore(productSnapshot as DocumentSnapshot<Map<String, dynamic>>);
            return produit.categorieRef.get().then((categorySnapshot) {
              var category = Categorie(
                id: categorySnapshot.id,
                nomDeCategorie: categorySnapshot['nomDeCategorie'],
              );
              if (!categoryCount.containsKey(category.nomDeCategorie)) {
                categoryCount[category.nomDeCategorie] = 0;
              }
              categoryCount[category.nomDeCategorie] = categoryCount[category.nomDeCategorie]! + lot.quantite;
            });
          }));
        }

        return FutureBuilder(
          future: Future.wait(futures),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<PieChartSectionData> sections = categoryCount.entries.map((entry) {
              final double percentage = calculatePercentage(entry.value, lots.length);
              return PieChartSectionData(
                value: entry.value.toDouble(),
                title: '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                showTitle: true,
              );
            }).toList();

            return PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    // Optional: Handle touch interactions
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class LotExpirationDistribution extends StatefulWidget {
  @override
  _LotExpirationDistributionState createState() => _LotExpirationDistributionState();
}

class _LotExpirationDistributionState extends State<LotExpirationDistribution> {
  String selectedPeriod = 'Tous'; // Par défaut, afficher tous les lots

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Distribution des Lots par Date d\'Expiration',
              description: 'Cette analyse montre la répartition des lots selon leur date d\'expiration.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.yellowAccent,
        child: SizedBox(
          height: 400, // Set a specific height for the Card
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Distribution par Date d'Expiration",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedPeriod,
                  onChanged: (value) {
                    setState(() {
                      selectedPeriod = value!;
                    });
                  },
                  items: ['Tous', '0-1 mois', '1-3 mois', '3-6 mois', '6+ mois']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('lots').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: Text('No Data Available'));
                      }

                      var lots = snapshot.data!.docs
                          .map((doc) => Lot.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
                          .toList();

                      // Filtrer les lots en fonction de la période sélectionnée
                      if (selectedPeriod != 'Tous') {
                        lots = lots.where((lot) {
                          var diff = lot.dateExpiration.toDate().difference(DateTime.now()).inDays;
                          if (selectedPeriod == '0-1 mois') {
                            return diff <= 30;
                          } else if (selectedPeriod == '1-3 mois') {
                            return diff > 30 && diff <= 90;
                          } else if (selectedPeriod == '3-6 mois') {
                            return diff > 90 && diff <= 180;
                          } else {
                            return diff > 180;
                          }
                        }).toList();
                      }

                      // Calculer la distribution des lots filtrés
                      Map<String, int> expirationCount = {
                        '0-1 mois': 0,
                        '1-3 mois': 0,
                        '3-6 mois': 0,
                        '6+ mois': 0,
                      };

                      for (var lot in lots) {
                        var diff = lot.dateExpiration.toDate().difference(DateTime.now()).inDays;
                        if (diff <= 30) {
                          expirationCount['0-1 mois'] = expirationCount['0-1 mois']! + lot.quantite;
                        } else if (diff <= 90) {
                          expirationCount['1-3 mois'] = expirationCount['1-3 mois']! + lot.quantite;
                        } else if (diff <= 180) {
                          expirationCount['3-6 mois'] = expirationCount['3-6 mois']! + lot.quantite;
                        } else {
                          expirationCount['6+ mois'] = expirationCount['6+ mois']! + lot.quantite;
                        }
                      }

                      List<PieChartSectionData> sections = expirationCount.entries.map((entry) {
                        final double percentage = calculatePercentage(entry.value, lots.length);
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                          color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                          showTitle: true,
                        );
                      }).toList();

                      return Column(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(sections: sections),
                            ),
                          ),
                          Text("Graphique de répartition des lots selon leur date d'expiration"),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double calculatePercentage(int count, int total) {
    return (total == 0) ? 0 : (count / total) * 100;
  }
}

class MostStockedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Produits les Plus Stockés',
              description: 'Cette analyse montre les produits ayant les stocks les plus élevés.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.lightGreenAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Produits les Plus Stockés",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('lots').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No Data Available'));
                  }

                  var lots = snapshot.data!.docs.map((doc) => Lot.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();

                  Map<String, int> productStockCount = {};
                  List<Future<void>> futures = [];

                  for (var lot in lots) {
                    futures.add(lot.produitRef.get().then((productSnapshot) {
                      var produit = Produit.fromFirestore(productSnapshot as DocumentSnapshot<Map<String, dynamic>>);
                      if (!productStockCount.containsKey(produit.nomDeProduit)) {
                        productStockCount[produit.nomDeProduit] = 0;
                      }
                      productStockCount[produit.nomDeProduit] = productStockCount[produit.nomDeProduit]! + lot.quantite;
                    }));
                  }

                  return FutureBuilder(
                    future: Future.wait(futures),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var sortedProducts = productStockCount.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      List<BarChartGroupData> barGroups = sortedProducts.map((entry) {
                        return BarChartGroupData(
                          x: sortedProducts.indexOf(entry),
                          barRods: [
                            BarChartRodData(
                              y: entry.value.toDouble(),
                              width: 20, // Set bar width
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                              colors: [Colors.lightBlue], // Set bar color
                              // Optional: Add a tooltip for each bar showing the product name and stock count
                              tooltipText: '${entry.key}\nStock: ${entry.value}',
                            ),
                          ],
                        );
                      }).toList();

                      return Column(
                        children: [
                          SizedBox(
                            height: 400,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: barGroups,
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) {
                                      if (value.toInt() < sortedProducts.length) {
                                        return sortedProducts[value.toInt()].key;
                                      }
                                      return '';
                                    },
                                  ),
                                  leftTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Cette analyse montre les produits ayant les stocks les plus élevés.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Je commente cette ligne car je n'ai pas l'accès à une base de données Firestore pour tester
  runApp(MaterialApp(home: DashboardScreen()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: DashboardScreen(),
  ));
}
*/