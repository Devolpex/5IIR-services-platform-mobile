import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/demande_service.dart';

class OfferDetailsPage extends StatefulWidget {
  final int offerId;

  const OfferDetailsPage({Key? key, required this.offerId}) : super(key: key);

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  final DemandeService _demandeService = DemandeService();
  Map<String, dynamic>? offerDetails;
  bool isLoading = true;
  bool isApproving = false;
  bool showSuccessMessage = false; // Variable pour afficher le message de succès

  @override
  void initState() {
    super.initState();
    fetchOfferDetails();
  }

  Future<void> fetchOfferDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _demandeService.getOfferDetails(widget.offerId);
      print("Détails de l'offre récupérés: $result"); // Debug
      setState(() {
        offerDetails = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la récupération des détails de l'offre."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> approveOffer() async {
    if (offerDetails == null) return;

    setState(() {
      isApproving = true;
    });

    try {
      await _demandeService.approveOffer(offerDetails!['id'], context);

      // Affichage du message de succès en haut
      setState(() {
        showSuccessMessage = true;
      });

      // Cacher le message après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          showSuccessMessage = false;
        });
        Navigator.pop(context); // Retour à la page précédente
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de l'approbation de l'offre."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isApproving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Arrière-plan doux
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Retour',
        ),
        title: Text(
          "Détails de l'Offre",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFD4AF37), // Doré pour le luxe
        elevation: 4,
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
            child: SpinKitCubeGrid(
              color: Color(0xFFD4AF37),
              size: 50.0,
            ),
          )
              : offerDetails != null
              ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icône et Titre
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: const Color(0xFFD4AF37),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Offre Spéciale",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Description
                        Text(
                          "Description:",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          offerDetails!['description'] ?? "Pas de description",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Tarif
                        Text(
                          "Tarif:",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${offerDetails!['tarif'] ?? 'N/A'} €",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Date Disponible
                        Text(
                          "Date Disponible:",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          offerDetails!['dateDisponible'] ?? "N/A",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Bouton d'Approbation
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: isApproving ? null : approveOffer,
                            icon: isApproving
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                                : const Icon(Icons.check, color: Colors.white),
                            label: isApproving
                                ? const Text("Chargement...")
                                : const Text(
                              "Approuver",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
              : const Center(
            child: Text(
              "Aucune information disponible.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
          // Message de succès en haut
          if (showSuccessMessage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Offre approuvée avec succès !",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          showSuccessMessage = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
