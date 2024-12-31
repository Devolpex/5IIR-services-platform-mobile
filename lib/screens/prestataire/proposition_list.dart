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
            // onChanged: onQueryChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: propositions.length,
            itemBuilder: (context, index) {
              final proposition = propositions[index];
              return Card(
                child: ListTile(
                  title: Text(proposition.description!),
                  subtitle: Text(proposition.description!),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
