import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/demande_service.dart';

class CreateDemandePage extends StatefulWidget {
  const CreateDemandePage({Key? key}) : super(key: key);

  @override
  State<CreateDemandePage> createState() => _CreateDemandePageState();
}

class _CreateDemandePageState extends State<CreateDemandePage> {
  final DemandeService _demandeService = DemandeService();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.amber,
            textTheme: GoogleFonts.montserratTextTheme(),
            colorScheme: ColorScheme.light(
              primary: Colors.amber,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> createDemande() async {
    if (_serviceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _lieuController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tous les champs sont obligatoires."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final demandeData = {
        "service": _serviceController.text,
        "description": _descriptionController.text,
        "lieu": _lieuController.text,
        "dateDisponible": _dateController.text,
      };
      await _demandeService.createDemande(demandeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande créée avec succès."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation de LayoutBuilder pour la réactivité
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        title: Text(
          "Créer une Demande",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Center(
                child: Container(
                  width: isWideScreen ? 600 : double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Remplissez les champs ci-dessous pour créer une demande :",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Service Field
                      CustomTextField(
                        controller: _serviceController,
                        labelText: "Service",
                        icon: Icons.work_outline,
                      ),
                      const SizedBox(height: 20),
                      // Description Field
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: "Description",
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      // Lieu Field
                      CustomTextField(
                        controller: _lieuController,
                        labelText: "Lieu",
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 20),
                      // Date Disponible Field
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: _dateController,
                            labelText: "Date Disponible",
                            icon: Icons.calendar_today_outlined,
                            suffixIcon: Icons.calendar_today,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Submit Button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : createDemande,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFFD4AF37),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(
                              "Créer la Demande",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget personnalisé pour les champs de texte
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final IconData? suffixIcon;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.suffixIcon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: const Color(0xFFD4AF37))
            : null,
        labelText: labelText,
        labelStyle: GoogleFonts.montserrat(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
        const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }
}
