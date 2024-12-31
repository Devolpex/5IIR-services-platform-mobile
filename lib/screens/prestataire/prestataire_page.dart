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
import 'demande_list.dart';
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
        return DemandeList();
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
          DemandeList(),
          OrderList(),
          OfferList(),
          PropositionList()
        ], 
      ),
      body: buildContent(),
    );
  }
}
