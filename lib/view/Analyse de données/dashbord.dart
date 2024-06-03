import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'analysedeux.dart';

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
      produitRef: data['produitRef'] ??
          FirebaseFirestore.instance.collection('produits').doc(),
      fournisseurRef: data['fournisseurRef'] ??
          FirebaseFirestore.instance.collection('fournisseurs').doc(),
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

  static Produit fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
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
              SizedBox(height: 16), // Ajout d'un espace supplémentaire
              ProductCategoryDistribution(),
              SizedBox(height: 16), // Ajout d'un espace supplémentaire
              ProductBrandDistribution(),
              SizedBox(height: 16), // Ajout d'un espace supplémentaire
              ExpiredNonExpiredLots(),
              SizedBox(
                  height:
                      16), // Ajout d'un espace supplémentaire// Ajout d'un espace supplémentaire
              LotExpirationDistribution(),
              SizedBox(height: 16), // Ajout d'un espace supplémentaire
              MostStockedProducts(),
              SizedBox(height: 16),

              SizedBox(height: 16),
// Ajout d'un espace supplémentaire
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCategoryDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Distribution des Produits par Catégorie',
              description:
                  'Cette analyse montre la répartition des produits selon les différentes catégories.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  .map((doc) => Lot.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>))
                  .toList();

              Map<String, int> categoryCount = {};
              int totalQuantity = 0;
              List<Future<void>> futures = [];

              for (var lot in lots) {
                totalQuantity += lot.quantite;
                futures.add(lot.produitRef.get().then((productSnapshot) {
                  var produit = Produit.fromFirestore(productSnapshot
                      as DocumentSnapshot<Map<String, dynamic>>);
                  return produit.categorieRef.get().then((categorySnapshot) {
                    var category = Categorie(
                      id: categorySnapshot.id,
                      nomDeCategorie: categorySnapshot['nomDeCategorie'],
                    );
                    if (!categoryCount.containsKey(category.nomDeCategorie)) {
                      categoryCount[category.nomDeCategorie] = 0;
                    }
                    categoryCount[category.nomDeCategorie] =
                        categoryCount[category.nomDeCategorie]! + lot.quantite;
                  });
                }));
              }

              return FutureBuilder(
                future: Future.wait(futures),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  String topCategory = categoryCount.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                      .key;
                  int topCategoryQuantity = categoryCount[topCategory]!;
                  double topCategoryPercentage =
                      (topCategoryQuantity / totalQuantity) * 100;

                  List<PieChartSectionData> sections =
                      categoryCount.entries.map((entry) {
                    final double percentage =
                        (entry.value / totalQuantity) * 100;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                      color: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)],
                      showTitle: true,
                    );
                  }).toList();

                  return Container(
                    height: 200,
                    child: Column(
                      children: [
                        Text("Distribution par Catégorie",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            'Catégorie la plus vendue: $topCategory ($topCategoryPercentage%)',
                            style: TextStyle(color: Colors.red)),
                        Expanded(
                          child: PieChart(
                            PieChartData(sections: sections),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProductBrandDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Distribution des Produits par Marque',
              description:
                  'Cette analyse montre la répartition des produits selon les différentes marques.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.lightGreenAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  .map((doc) => Lot.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>))
                  .toList();

              Map<String, int> brandCount = {};
              int totalQuantity = 0;
              List<Future<void>> futures = [];

              for (var lot in lots) {
                totalQuantity += lot.quantite;
                futures.add(lot.produitRef.get().then((productSnapshot) {
                  var produit = Produit.fromFirestore(productSnapshot
                      as DocumentSnapshot<Map<String, dynamic>>);
                  return produit.marqueRef.get().then((brandSnapshot) {
                    var brand = Marque(
                      id: brandSnapshot.id,
                      nomDeMarque: brandSnapshot['nomDeMarque'],
                    );
                    if (!brandCount.containsKey(brand.nomDeMarque)) {
                      brandCount[brand.nomDeMarque] = 0;
                    }
                    brandCount[brand.nomDeMarque] =
                        brandCount[brand.nomDeMarque]! + lot.quantite;
                  });
                }));
              }

              return FutureBuilder(
                future: Future.wait(futures),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  String topBrand = brandCount.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                      .key;
                  int topBrandQuantity = brandCount[topBrand]!;
                  double topBrandPercentage =
                      (topBrandQuantity / totalQuantity) * 100;

                  List<PieChartSectionData> sections =
                      brandCount.entries.map((entry) {
                    final double percentage =
                        (entry.value / totalQuantity) * 100;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                      color: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)],
                      showTitle: true,
                    );
                  }).toList();

                  return Container(
                    height: 200,
                    child: Column(
                      children: [
                        Text("Distribution par Marque",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            'Marque la plus vendue: $topBrand ($topBrandPercentage%)',
                            style: TextStyle(color: Colors.red)),
                        Expanded(
                          child: PieChart(
                            PieChartData(sections: sections),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ExpiredNonExpiredLots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedChartPage(
              title: 'Lots Expirés et Non Expirés',
              description:
                  'Cette analyse montre la répartition des lots expirés et non expirés.',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.orangeAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  .map((doc) => Lot.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>))
                  .toList();

              int expiredCount = 0;
              int nonExpiredCount = 0;

              for (var lot in lots) {
                if (lot.dateExpiration.toDate().isBefore(DateTime.now())) {
                  expiredCount += lot.quantite;
                } else {
                  nonExpiredCount += lot.quantite;
                }
              }

              List<PieChartSectionData> sections = [
                PieChartSectionData(
                  value: expiredCount.toDouble(),
                  title:
                      'Expirés\n${calculatePercentage(expiredCount, expiredCount + nonExpiredCount).toStringAsFixed(2)}%', // Ajout des pourcentages et des noms
                  color: Colors.redAccent,
                  showTitle: true,
                ),
                PieChartSectionData(
                  value: nonExpiredCount.toDouble(),
                  title:
                      'Non Expirés\n${calculatePercentage(nonExpiredCount, expiredCount + nonExpiredCount).toStringAsFixed(2)}%', // Ajout des pourcentages et des noms
                  color: Colors.greenAccent,
                  showTitle: true,
                ),
              ];

              return Container(
                height:
                    200, // Set a specific height to avoid infinite height issue
                child: Column(
                  children: [
                    Text("Lots Expirés vs Non Expirés",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: PieChart(
                        PieChartData(sections: sections),
                      ),
                    ),
                  ],
                ),
              );
            },
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
            Text(title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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

        var lots = snapshot.data!.docs
            .map((doc) => Lot.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        Map<String, int> categoryCount = {};
        List<Future<void>> futures = [];

        for (var lot in lots) {
          futures.add(lot.produitRef.get().then((productSnapshot) {
            var produit = Produit.fromFirestore(
                productSnapshot as DocumentSnapshot<Map<String, dynamic>>);
            return produit.categorieRef.get().then((categorySnapshot) {
              var category = Categorie(
                id: categorySnapshot.id,
                nomDeCategorie: categorySnapshot['nomDeCategorie'],
              );
              if (!categoryCount.containsKey(category.nomDeCategorie)) {
                categoryCount[category.nomDeCategorie] = 0;
              }
              categoryCount[category.nomDeCategorie] =
                  categoryCount[category.nomDeCategorie]! + lot.quantite;
            });
          }));
        }

        return FutureBuilder(
          future: Future.wait(futures),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<PieChartSectionData> sections =
                categoryCount.entries.map((entry) {
              final double percentage =
                  calculatePercentage(entry.value, lots.length);
              return PieChartSectionData(
                value: entry.value.toDouble(),
                title: '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                showTitle: true,
              );
            }).toList();

            return PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback:
                      (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
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
  _LotExpirationDistributionState createState() =>
      _LotExpirationDistributionState();
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
              description:
                  'Cette analyse montre la répartition des lots selon leur date d\'expiration.',
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
                          .map((doc) => Lot.fromFirestore(
                              doc as DocumentSnapshot<Map<String, dynamic>>))
                          .toList();

                      // Filtrer les lots en fonction de la période sélectionnée
                      if (selectedPeriod != 'Tous') {
                        lots = lots.where((lot) {
                          var diff = lot.dateExpiration
                              .toDate()
                              .difference(DateTime.now())
                              .inDays;
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
                        var diff = lot.dateExpiration
                            .toDate()
                            .difference(DateTime.now())
                            .inDays;
                        if (diff <= 30) {
                          expirationCount['0-1 mois'] =
                              expirationCount['0-1 mois']! + lot.quantite;
                        } else if (diff <= 90) {
                          expirationCount['1-3 mois'] =
                              expirationCount['1-3 mois']! + lot.quantite;
                        } else if (diff <= 180) {
                          expirationCount['3-6 mois'] =
                              expirationCount['3-6 mois']! + lot.quantite;
                        } else {
                          expirationCount['6+ mois'] =
                              expirationCount['6+ mois']! + lot.quantite;
                        }
                      }

                      int totalLots = expirationCount.values
                          .fold(0, (sum, item) => sum + item);

                      List<PieChartSectionData> sections =
                          expirationCount.entries.map((entry) {
                        final double percentage =
                            totalLots > 0 ? (entry.value / totalLots) * 100 : 0;
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title:
                              '${entry.key}\n${percentage.toStringAsFixed(2)}%',
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
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
                          Text(
                              "Graphique de répartition des lots selon leur date d'expiration"),
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
              description:
                  'Cette analyse montre les produits ayant les stocks les plus élevés.',
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

                  var lots = snapshot.data!.docs
                      .map((doc) => Lot.fromFirestore(
                          doc as DocumentSnapshot<Map<String, dynamic>>))
                      .toList();

                  Map<String, int> productStockCount = {};
                  List<Future<void>> futures = [];

                  for (var lot in lots) {
                    futures.add(lot.produitRef.get().then((productSnapshot) {
                      var produit = Produit.fromFirestore(productSnapshot
                          as DocumentSnapshot<Map<String, dynamic>>);
                      if (!productStockCount
                          .containsKey(produit.nomDeProduit)) {
                        productStockCount[produit.nomDeProduit] = 0;
                      }
                      productStockCount[produit.nomDeProduit] =
                          productStockCount[produit.nomDeProduit]! +
                              lot.quantite;
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

                      var top3Products = sortedProducts.take(3).toList();
                      bool hasMoreProducts = sortedProducts.length > 3;
                      var mostStockedProduct = sortedProducts.isNotEmpty
                          ? sortedProducts.first.key
                          : null;

                      List<BarChartGroupData> barGroups =
                          top3Products.map((entry) {
                        Color barColor = Colors.lightBlue; // Couleur par défaut
                        if (entry.key.toLowerCase().contains('délice')) {
                          barColor = Colors.blue;
                        } else if (entry.key.toLowerCase().contains('saida')) {
                          barColor = Colors.green;
                        }

                        return BarChartGroupData(
                          x: top3Products.indexOf(entry),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: barColor,
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
                                      getTitlesWidget: (value, meta) {
                                        if (value < top3Products.length) {
                                          return Text(
                                              top3Products[value.toInt()].key);
                                        }
                                        return Text('');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          if (hasMoreProducts)
                            Text(
                              "Et plus...",
                              style: TextStyle(
                                  fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          SizedBox(height: 8),
                          Text(
                            "Cette analyse montre les produits ayant les stocks les plus élevés. "
                            "Par exemple, ${mostStockedProduct ?? 'Aucun produit'} a le stock le plus élevé actuellement.",
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
