import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/screens/prestataire/order_list.dart';
import 'package:mobile/screens/prestataire/proposition_list.dart';

import '../../models/demande_model.dart';
import '../../services/auth_service.dart';
import '../../services/demande_service.dart';
import '../../utils/colors.dart';
import '../../utils/menu.dart';
import '../welcome.dart';
import 'offer_list.dart';

class PrestatairePage extends StatefulWidget {
  const PrestatairePage({Key? key}) : super(key: key);

  @override
  State<PrestatairePage> createState() => _PrestatairePageState();
}

class _PrestatairePageState extends State<PrestatairePage> {
  final Logger logger = Logger();
  final DemandeService demandeService = DemandeService();

  final List<String> menuItems = [
    "Demande List",
    "Offer List",
    "Order List",
    "Proposition List",
  ];

  int selectedIndex = 0;

  List<Demande> demandes = [];
  List<Demande> searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchDemandes(); // Load initial data for Demande List
  }

  Future<void> fetchDemandes() async {
    try {
      final fetchedDemandes = await demandeService.getDemandesPage();
      setState(() {
        demandes = fetchedDemandes;
      });
    } catch (e) {
      logger.e("Failed to fetch demandes: $e");
    }
  }

  void onQueryChanged(String query) {
    setState(() {
      searchResults = demandes
          .where((demande) =>
              demande.service.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget buildContent() {
    switch (selectedIndex) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search demandes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onQueryChanged,
              ),
            ),
            Expanded(
              child: demandes.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: searchResults.isEmpty
                          ? demandes.length
                          : searchResults.length,
                      itemBuilder: (context, index) {
                        final demande = searchResults.isEmpty
                            ? demandes[index]
                            : searchResults[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  demande.service,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text("Demandeur: ${demande.demandeur.name}"),
                                Text("Lieu: ${demande.lieu}"),
                                Text("Date: ${demande.createdAt}"),
                                Text("Service: ${demande.service}"),
                                Text("Description: ${demande.description}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      case 1:
        return OfferList();
      case 2:
        return OrderList();
      case 3:
        return PropositionList();
      default:
        return Center(child: Text("Invalid selection"));
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i("PrestatairePage build, selectedIndex: $selectedIndex");

    return Scaffold(
      appBar: AppBar(
        backgroundColor:primary,
        foregroundColor: Colors.white,
        title: Text(menuItems[selectedIndex],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              AuthService().removeAuth();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Menu(
        menuItems: menuItems,
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        pages: [
          OrderList(),
          OfferList(),
          PropositionList()
        ], 
      ),
      body: buildContent(),
    );
  }
}
