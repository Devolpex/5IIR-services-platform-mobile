import 'package:flutter/material.dart';
import '../../services/demande_service.dart';

class FormulaireDemande extends StatefulWidget {
  final Map<String, dynamic>? demande;

  const FormulaireDemande({Key? key, this.demande}) : super(key: key);

  @override
  State<FormulaireDemande> createState() => _FormulaireDemandeState();
}

class _FormulaireDemandeState extends State<FormulaireDemande> {
  final _formKey = GlobalKey<FormState>();
  String description = "";
  String lieu = "";
  String service = "";

  @override
  void initState() {
    super.initState();
    if (widget.demande != null) {
      description = widget.demande!['description'] ?? "";
      lieu = widget.demande!['lieu'] ?? "";
      service = widget.demande!['service'] ?? "";
    }
  }

  Future<void> saveDemande() async {
    final demandeService = DemandeService();
    if (widget.demande == null) {
      await demandeService.createDemande({
        "description": description,
        "lieu": lieu,
        "service": service,
      });
    } else {
      await demandeService.updateDemande(widget.demande!['id'], {
        "description": description,
        "lieu": lieu,
        "service": service,
      });
    }
    Navigator.pop(context, true); // Retour après enregistrement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          widget.demande == null ? "Créer une Demande" : "Modifier la Demande",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Veuillez remplir les informations suivantes :",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => description = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La description est obligatoire";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: lieu,
                  decoration: InputDecoration(
                    labelText: "Lieu",
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => lieu = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le lieu est obligatoire";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: service,
                  decoration: InputDecoration(
                    labelText: "Service",
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => service = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le service est obligatoire";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveDemande();
                      }
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Enregistrer",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
  }
}
