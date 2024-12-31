import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/demande_service.dart';

class MyDemandesPage extends StatefulWidget {
  const MyDemandesPage({Key? key}) : super(key: key);

  @override
  State<MyDemandesPage> createState() => _MyDemandesPageState();
}

class _MyDemandesPageState extends State<MyDemandesPage> with SingleTickerProviderStateMixin {
  final DemandeService _demandeService = DemandeService();
  List<dynamic> demandes = [];
  bool isLoading = true;

  // Champs pour la demande en cours d'édition
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int? editingDemandeId; // Stocke l'ID de la demande en cours d'édition

  // Animation Controller pour les transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    loadDemandes();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _serviceController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> loadDemandes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _demandeService.getUserDemandes();
      setState(() {
        demandes = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la récupération des demandes.")),
      );
    }
  }

  Future<void> deleteDemande(int id) async {
    try {
      await _demandeService.deleteDemande(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande supprimée avec succès.")),
      );
      loadDemandes(); // Recharger les demandes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4AF37), // Or métallique
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> updateDemande() async {
    if (_serviceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _lieuController.text.isEmpty ||
        _dateController.text.isEmpty ||
        editingDemandeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final updatedDemandeData = {
        "service": _serviceController.text,
        "description": _descriptionController.text,
        "lieu": _lieuController.text,
        "dateDisponible": _dateController.text,
      };
      await _demandeService.updateDemande(editingDemandeId!, updatedDemandeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande mise à jour avec succès.")),
      );
      Navigator.pop(context); // Fermer le modal
      loadDemandes(); // Recharger les demandes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour : ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addDemande() async {
    if (_serviceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _lieuController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final newDemandeData = {
        "service": _serviceController.text,
        "description": _descriptionController.text,
        "lieu": _lieuController.text,
        "dateDisponible": _dateController.text,
      };
      await _demandeService.createDemande(newDemandeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande ajoutée avec succès.")),
      );
      Navigator.pop(context); // Fermer le modal
      loadDemandes(); // Recharger les demandes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout : ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void openEditModal(Map<String, dynamic> demande) {
    setState(() {
      editingDemandeId = demande['id'];
      _serviceController.text = demande['service'];
      _descriptionController.text = demande['description'];
      _lieuController.text = demande['lieu'];
      _dateController.text = demande['dateDisponible']; // Date déjà formatée
    });

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Modifier la Demande",
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_serviceController, "Service", Icons.build, const Color(0xFFD4AF37)),
                    const SizedBox(height: 15),
                    _buildTextField(_descriptionController, "Description", Icons.description, const Color(0xFFD4AF37)),
                    const SizedBox(height: 15),
                    _buildTextField(_lieuController, "Lieu", Icons.location_on, const Color(0xFFD4AF37)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37)),
                        labelText: "Date Disponible",
                        labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: updateDemande,
                      child: const Text("Mettre à jour"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
    );
  }

  void openAddModal() {
    setState(() {
      editingDemandeId = null;
      _serviceController.text = '';
      _descriptionController.text = '';
      _lieuController.text = '';
      _dateController.text = '';
    });

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ajouter une Demande",
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_serviceController, "Service", Icons.build, const Color(0xFFD4AF37)),
                    const SizedBox(height: 15),
                    _buildTextField(_descriptionController, "Description", Icons.description, const Color(0xFFD4AF37)),
                    const SizedBox(height: 15),
                    _buildTextField(_lieuController, "Lieu", Icons.location_on, const Color(0xFFD4AF37)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37)),
                        labelText: "Date Disponible",
                        labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: addDemande,
                      child: const Text("Ajouter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, Color iconColor) {
    return TextField(
      controller: controller,
      style: GoogleFonts.roboto(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        labelText: label,
        labelStyle: TextStyle(color: iconColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Arrière-plan gris clair
      appBar: AppBar(
        title: Text(
          "Mes Demandes",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD4AF37),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isLoading
            ? Center(
          child: SpinKitPulse(
            color: const Color(0xFFD4AF37),
            size: 60.0,
          ),
        )
            : demandes.isEmpty
            ? const Center(
          child: Text(
            "Aucune demande trouvée.",
            style: TextStyle(fontSize: 20, color: Color(0xFFD4AF37)),
          ),
        )
            : RefreshIndicator(
          onRefresh: loadDemandes,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            itemCount: demandes.length,
            itemBuilder: (context, index) {
              final demande = demandes[index];
              return DemandeCard(
                demande: demande,
                onEdit: () => openEditModal(demande),
                onDelete: () => deleteDemande(demande['id']),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddModal,
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 6,
      ),
    );
  }
}

class DemandeCard extends StatefulWidget {
  final Map<String, dynamic> demande;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DemandeCard({
    Key? key,
    required this.demande,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DemandeCard> createState() => _DemandeCardState();
}

class _DemandeCardState extends State<DemandeCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _isHovering ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovering
              ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFD4AF37),
            child: Text(
              widget.demande['service'][0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            widget.demande['service'],
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          subtitle: Text(
            widget.demande['description'],
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onHover(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
  }
}
