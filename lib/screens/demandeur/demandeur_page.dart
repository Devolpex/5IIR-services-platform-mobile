import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/utils/colors.dart';
import '../../services/auth_service.dart';
import '../welcome.dart';
import 'OfferDetailsPage.dart';
import 'CreateDemandePage.dart';
import 'MyDemandesPage.dart';
import 'ApprovedDemandesPage.dart';
import '../../services/demande_service.dart';

class DemandeurPage extends StatefulWidget {
  const DemandeurPage({Key? key}) : super(key: key);

  @override
  State<DemandeurPage> createState() => _DemandeurPageState();
}

class _DemandeurPageState extends State<DemandeurPage> {
  final DemandeService _demandeService = DemandeService();
  List<dynamic> offres = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadOffres();
  }

  Future<void> loadOffres() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _demandeService.getOffres();
      setState(() {
        offres = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur lors de la récupération des offres : $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Espace Demandeur",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        actions: [
          IconButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(8),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // sign-out logic here
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              // Smaller, Modern Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CompactButton(
                    text: "Créer",
                    icon: Icons.create,
                    color: Colors.amber,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateDemandePage(),
                        ),
                      );
                    },
                  ),
                  CompactButton(
                    text: "Demandes",
                    icon: Icons.list_alt,
                    color: Colors.blueGrey,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyDemandesPage(),
                        ),
                      );
                    },
                  ),
                  CompactButton(
                    text: "Offres",
                    icon: Icons.visibility,
                    color: Colors.teal,
                    onPressed: loadOffres,
                  ),
                  CompactButton(
                    text: "Approuvées",
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApprovedDemandesPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Offers Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                )
                    : errorMessage != null
                    ? _buildErrorState()
                    : offres.isEmpty
                    ? _buildEmptyState()
                    : _buildOffresList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateDemandePage(),
          ),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 6,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage!,
            style: GoogleFonts.montserrat(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loadOffres,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Aucune offre disponible",
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOffresList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: offres.length,
      itemBuilder: (context, index) {
        final offre = offres[index];
        return CompactCard(
          offre: offre,
          onDetails: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfferDetailsPage(offerId: offre['id']),
              ),
            );
          },
        );
      },
    );
  }
}

// CompactButton Widget
class CompactButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const CompactButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
      label: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(70, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
    );
  }
}

// CompactCard Widget
class CompactCard extends StatelessWidget {
  final Map<String, dynamic> offre;
  final VoidCallback onDetails;

  const CompactCard({
    Key? key,
    required this.offre,
    required this.onDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD4AF37),
          child: const Icon(Icons.local_offer, color: Colors.white),
        ),
        title: Text(
          offre['description'] ?? "Pas de description",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          "Tarif : ${offre['tarif']?.toString() ?? 'N/A'} €",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text(
            "Détails",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
