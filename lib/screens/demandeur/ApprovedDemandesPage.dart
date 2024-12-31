import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/demande_service.dart';

class ApprovedDemandesPage extends StatefulWidget {
  const ApprovedDemandesPage({Key? key}) : super(key: key);

  @override
  State<ApprovedDemandesPage> createState() => _ApprovedDemandesPageState();
}

class _ApprovedDemandesPageState extends State<ApprovedDemandesPage> {
  final DemandeService _demandeService = DemandeService();
  List<dynamic> approvedDemandes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadApprovedDemandes();
  }

  Future<void> loadApprovedDemandes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _demandeService.getApprovedDemandes();
      print("Demandes approuvées récupérées: $result"); // Debug
      setState(() {
        approvedDemandes = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur lors de la récupération des demandes approuvées : $e";
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de la récupération des demandes approuvées.",
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Arrière-plan doux
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37), // Doré pour le luxe
        title: Text(
          "Demandes Approuvées",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
          child: SpinKitCircle(
            color: Color(0xFFD4AF37),
            size: 50.0,
          ),
        )
            : errorMessage != null
            ? _buildErrorState()
            : approvedDemandes.isEmpty
            ? _buildEmptyState()
            : _buildApprovedDemandesList(),
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: loadApprovedDemandes,
            icon: const Icon(Icons.refresh),
            label: Text(
              "Réessayer",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.grey[600],
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune demande approuvée trouvée.",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedDemandesList() {
    return ListView.builder(
      itemCount: approvedDemandes.length,
      itemBuilder: (context, index) {
        final demande = approvedDemandes[index];
        final service = demande['demande']?['service'] ?? "Service inconnu";
        final description = demande['demande']?['description'] ?? "Pas de description";
        final lieu = demande['demande']?['lieu'] ?? "Non spécifié";
        final dateDisponible = demande['demande']?['dateDisponible'] ?? "Non spécifiée";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFD4AF37),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
              ),
              title: Text(
                service,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          lieu,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          dateDisponible,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: const Icon(
                Icons.verified,
                color: Colors.green,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
