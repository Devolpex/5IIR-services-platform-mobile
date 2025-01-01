import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/proposition_service.dart';
import 'package:mobile/models/dto/propositionDto.dart';

class PropositionList extends StatefulWidget {
  const PropositionList({Key? key}) : super(key: key);

  @override
  State<PropositionList> createState() => _PropositionListState();
}

class _PropositionListState extends State<PropositionList> {
  final Logger logger = Logger();
  final PropositionService propositionService = PropositionService();
  final AuthService authService = AuthService();

  List<Propositiondto> propositions = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPropositions();
  }

  Future<void> _fetchPropositions() async {
    final prestataireId = await authService.getAuthId();
    logger.i("fetchPropositions, prestataireId: $prestataireId");
    try {
      final fetchedPropositions = await propositionService.getPropositionByPrestataireId(prestataireId!);
      logger.i("fetchedPropositions: $fetchedPropositions");
      setState(() {
        propositions = fetchedPropositions;
      });
    } catch (e) {
      logger.e("Failed to fetch propositions: $e");
    }
  }

  Future<void> _deleteProposition(int id) async {
    try {
      await propositionService.deletePropositionById(id);
      setState(() {
        propositions.removeWhere((p) => p.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proposition deleted successfully")),
      );
    } catch (e) {
      logger.e("Failed to delete proposition: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete proposition")),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this proposition?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteProposition(id);
    }
  }

  void _showUpdateForm(BuildContext context, Propositiondto proposition) {
    final TextEditingController descriptionController = TextEditingController(text: proposition.description);
    final TextEditingController priceController = TextEditingController(text: proposition.tarifProposer.toString());
    final TextEditingController dateController = TextEditingController(text: proposition.dateDisponible.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Proposition"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "Tariff Proposer",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Date Disponible",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,  // Make the field read-only to avoid direct text input
                  onTap: () async {
                    // Show date picker
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: proposition.dateDisponible ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (selectedDate != null) {
                      // Show time picker
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(proposition.dateDisponible ?? DateTime.now()),
                      );

                      if (selectedTime != null) {
                        // Combine date and time into a single DateTime object
                        DateTime selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        
                        dateController.text = selectedDateTime.toString();  // Update the text field with the selected DateTime
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final Propositiondto updatedProposition = Propositiondto (
                  description: descriptionController.text,
                  tarifProposer: double.tryParse(priceController.text),
                  dateDisponible: DateTime.tryParse(dateController.text),
                );
                _updateProposition(updatedProposition, proposition.id!);
                Navigator.of(context).pop();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProposition(Propositiondto proposition, int id) async {
    try {
      await propositionService.updateProposition(proposition, id);
      setState(() {
        final index = propositions.indexWhere((p) => p.id == id);
        if (index != -1) {
          propositions[index] = proposition;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proposition updated successfully")),
      );
    } catch (e) {
      logger.e("Failed to update proposition: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update proposition")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search proposition...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: propositions.length,
            itemBuilder: (context, index) {
              final proposition = propositions[index];
              if (!proposition.description!.toLowerCase().contains(searchQuery.toLowerCase())) {
                return Container();
              }
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposition.description ?? "No description available",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "${proposition.tarifProposer ?? 0.0} TND",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            proposition.dateDisponible.toString() ?? "No date available",
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _confirmDelete(context, proposition.id!),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Delete"),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _showUpdateForm(context, proposition),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Update"),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Proposition Details"),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: [
                                          Text("Description: ${proposition.description}"),
                                          const SizedBox(height: 8),
                                          Text("TariffProposer: ${proposition.tarifProposer} TND"),
                                          const SizedBox(height: 8),
                                          Text("Available Date: ${proposition.dateDisponible}"),
                                          const SizedBox(height: 8),
                                          Text("Service: ${proposition.demande?.service ?? "Unknown"}"),
                                          const SizedBox(height: 8),
                                          Text("Location: ${proposition.demande?.lieu ?? "Unknown"}"),
                                          const SizedBox(height: 8),
                                          Text("Demandeur: ${proposition.demande?.demandeur?.nom ?? "Unknown"}"),
                                          const SizedBox(height: 8),
                                          Text("Provider Email: ${proposition.prestataire?.email ?? "Unknown"}"),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Details"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
