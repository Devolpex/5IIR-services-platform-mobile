import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/models/demande_model.dart';
import 'package:mobile/services/demande_service.dart';
import 'package:mobile/utils/colors.dart';

class PrestatairePage extends StatefulWidget {
  const PrestatairePage({Key? key}) : super(key: key);

  @override
  State<PrestatairePage> createState() => _PrestatairePageState();
}

class _PrestatairePageState extends State<PrestatairePage> {
  Logger logger = Logger();
  final DemandeService demandeService = DemandeService();

  // List of menu items
  final List<String> menuItems = [
    "Demande List",
    "Proposition List",
    "Offer List",
    "Order List",
  ];

  // Current selected menu index
  int selectedIndex = 0;

  // List of demandes
  List<Demande> demandes = [];

  @override
  void initState() {
    super.initState();
    if (selectedIndex == 0) {
      fetchDemandes();
    }
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

  @override
  Widget build(BuildContext context) {
    logger.i("PrestatairePage build, selectedIndex: $selectedIndex");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Text(menuItems[selectedIndex], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Update title dynamically
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Handle profile button press
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 110,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.rectangle,
                ),
                margin: EdgeInsets.zero,
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ...List.generate(menuItems.length, (index) {
              return ListTile(
                title: Text(menuItems[index]),
                selected: selectedIndex == index, // Highlight selected item
                onTap: () {
                  setState(() {
                    selectedIndex = index; // Update selected index
                    if (selectedIndex == 0) {
                      fetchDemandes();
                    }
                  });
                  Navigator.pop(context); // Close the drawer
                },
              );
            }),
          ],
        ),
      ),
      body: Center(
        child: selectedIndex == 0
            ? ListView.builder(
                itemCount: demandes.length,
                itemBuilder: (context, index) {
                  final demande = demandes[index];
                  return ListTile(
                    title: Text(demande.service),
                    subtitle: Text(demande.description),
                  );
                },
              )
            : Text(menuItems[selectedIndex], style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}