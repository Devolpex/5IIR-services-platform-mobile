import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../models/demande_model.dart';
import '../../services/demande_service.dart';

class DemandeList extends StatefulWidget {
const DemandeList({ Key? key }) : super(key: key);

  @override
  State<DemandeList> createState() => _DemandeListState();
}


int selectedIndex = 0;

  List<Demande> demandes = [];
  List<Demande> searchResults = [];

  


class _DemandeListState extends State<DemandeList> {

  final Logger logger = Logger();
  final DemandeService demandeService = DemandeService();

  int selectedIndex = 0;

  List<Demande> demandes = [];
  List<Demande> searchResults = [];
  
   @override
  void initState() {
    super.initState();
    fetchDemandes(); // Load initial data for Demande List
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

  void onAproved(){
    print("Aproved");
  }

  void onQueryChanged(String query) {
    setState(() {
      searchResults = demandes
          .where((demande) =>
              demande.service.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context){
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search demandes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onQueryChanged,
              ),
            ),
            Expanded(
              child: demandes.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: searchResults.isEmpty
                          ? demandes.length
                          : searchResults.length,
                      itemBuilder: (context, index) {
                        final demande = searchResults.isEmpty
                            ? demandes[index]
                            : searchResults[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  demande.service,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text("Demandeur: ${demande.demandeur.name}"),
                                Text("Lieu: ${demande.lieu}"),
                                Text("Date: ${demande.createdAt}"),
                                Text("Service: ${demande.service}"),
                                Text("Description: ${demande.description}"),
                               Row(children: [
                                FilledButton(
                                  onPressed: onAproved, style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white
                                  ),
                                  child: Text("Approuved"),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: onAproved,style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green[900],
                                    foregroundColor: Colors.white
                                  ),
                                
                                  child: Text("Details"),
                                ),
                               ],),
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