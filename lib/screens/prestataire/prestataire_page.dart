import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/models/demande_model.dart';
import 'package:mobile/models/proposition_model.dart';
import 'package:mobile/screens/welcome.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/demande_service.dart';
import 'package:mobile/services/proposition_service.dart';
import 'package:mobile/utils/colors.dart';

class PrestatairePage extends StatefulWidget {
  const PrestatairePage({Key? key}) : super(key: key);

  @override
  State<PrestatairePage> createState() => _PrestatairePageState();
}

class _PrestatairePageState extends State<PrestatairePage> {
  final Logger logger = Logger();
  final DemandeService demandeService = DemandeService();
  final PropositionService propositionService = PropositionService();

  // List of menu items
  final List<String> menuItems = [
    "Demande List",
    "Proposition List",
    "Offer List",
    "Order List",
  ];

  // Current selected menu index
  int selectedIndex = 0;

  // List of demandes and propositions
  List<Demande> demandes = [];
  List<Proposition> propositions = [];

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

  Future<void> fetchPropositions(String prestataireId) async {
    try {
      final fetchedPropositions =
          await propositionService.getPropositionByPrestataireId(prestataireId);
      setState(() {
        propositions = fetchedPropositions;
      });
    } catch (e) {
      logger.e("Failed to fetch propositions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i("PrestatairePage build, selectedIndex: $selectedIndex");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
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
                MaterialPageRoute(
                    builder: (context) => WelcomeScreen()),
              );           
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
                selected: selectedIndex == index,
                onTap: () async {
                  setState(() {
                    selectedIndex = index;
                  });
                  if (selectedIndex == 0) {
                    await fetchDemandes();
                  } else if (selectedIndex == 1) {
                    await fetchPropositions("PRESTATAIRE_ID");
                  }
                  Navigator.pop(context);
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
            : selectedIndex == 1
                ? ListView.builder(
                    itemCount: propositions.length,
                    itemBuilder: (context, index) {
                      final proposition = propositions[index];
                      return ListTile(
                        title: Text(proposition.description),
                        subtitle: Text(proposition.description),
                      );
                    },
                  )
                : Text(menuItems[selectedIndex],
                    style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
