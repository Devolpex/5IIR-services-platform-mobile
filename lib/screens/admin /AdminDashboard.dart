// lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/AdminService.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  List<dynamic> demandes = [];
  List<dynamic> offres = [];
  bool isLoading = true;
  String activeTab = 'dashboard'; // Par défaut, afficher le dashboard

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final demandesData = await _adminService.getDemandes();
      final offresData = await _adminService.getOffres();
      setState(() {
        demandes = demandesData;
        offres = offresData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du chargement des données.")),
      );
    }
  }

  Future<void> deleteDemande(int id) async {
    try {
      await _adminService.deleteDemande(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande supprimée avec succès.")),
      );
      loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  Future<void> deleteOffre(int id) async {
    try {
      await _adminService.deleteOffre(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offre supprimée avec succès.")),
      );
      loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  void switchTab(String tab) {
    setState(() {
      activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre latérale de navigation
      drawer: Drawer(
        child: SidebarContent(
          activeTab: activeTab,
          switchTab: switchTab,
        ),
      ),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.montserrat(),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: SpinKitPulse(
          color: Colors.blue,
          size: 60.0,
        ),
      )
          : Row(
        children: [
          // Barre latérale permanente pour les écrans larges
          if (MediaQuery.of(context).size.width > 800)
            SizedBox(
              width: 250,
              child: SidebarContent(
                activeTab: activeTab,
                switchTab: switchTab,
              ),
            ),
          // Contenu principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActiveTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (activeTab) {
      case 'dashboard':
        return DashboardContent(
          demandesCount: demandes.length,
          offresCount: offres.length,
          demandes: demandes,
          offres: offres,
        );
      case 'demandes':
        return DemandesList(
          demandes: demandes,
          onDelete: deleteDemande,
        );
      case 'offres':
        return OffresList(
          offres: offres,
          onDelete: deleteOffre,
        );
      default:
        return Center(
          child: Text(
            "Section non trouvée",
            style: GoogleFonts.montserrat(fontSize: 18),
          ),
        );
    }
  }

  String _getAppBarTitle() {
    switch (activeTab) {
      case 'dashboard':
        return 'Dashboard';
      case 'demandes':
        return 'Demandes';
      case 'offres':
        return 'Offres';
      default:
        return 'Admin Dashboard';
    }
  }
}

class SidebarContent extends StatelessWidget {
  final String activeTab;
  final Function(String) switchTab;

  const SidebarContent({
    Key? key,
    required this.activeTab,
    required this.switchTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header du Sidebar
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Admin Dashboard',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        // Items de navigation
        SidebarItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          tab: 'dashboard',
          activeTab: activeTab,
          switchTab: switchTab,
        ),
        SidebarItem(
          icon: Icons.file_copy,
          title: 'Demandes',
          tab: 'demandes',
          activeTab: activeTab,
          switchTab: switchTab,
        ),
        SidebarItem(
          icon: Icons.local_offer,
          title: 'Offres',
          tab: 'offres',
          activeTab: activeTab,
          switchTab: switchTab,
        ),
      ],
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tab;
  final String activeTab;
  final Function(String) switchTab;

  const SidebarItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.tab,
    required this.activeTab,
    required this.switchTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = activeTab == tab;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        switchTab(tab);
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context); // Fermer le drawer si ouvert
        }
      },
    );
  }
}

class DashboardContent extends StatelessWidget {
  final int demandesCount;
  final int offresCount;
  final List<dynamic> demandes;
  final List<dynamic> offres;

  const DashboardContent({
    Key? key,
    required this.demandesCount,
    required this.offresCount,
    required this.demandes,
    required this.offres,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Indicateurs KPI
          Text(
            "Indicateurs Clés de Performance",
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ResponsiveGrid(
            children: [
              KpiCard(
                title: "Demandes",
                count: demandesCount,
                color: Colors.blue,
              ),
              KpiCard(
                title: "Offres",
                count: offresCount,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Graphiques
          Text(
            "Graphiques",
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ResponsiveGrid(
            children: [
              ChartCard(
                title: "Demandes par Mois",
                child: DemandesLineChart(demandes: demandes),
              ),
              ChartCard(
                title: "Répartition Offres vs Demandes",
                child: OffresPieChart(
                  demandesCount: demandesCount,
                  offresCount: offresCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Bouton d'Actualisation
          ElevatedButton.icon(
            onPressed: () {
              // Implémenter la fonction d'actualisation si nécessaire
              // Vous pouvez utiliser un callback ou une méthode de votre StatefulWidget
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Actualiser les Données"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: GoogleFonts.montserrat(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const KpiCard({
    Key? key,
    required this.title,
    required this.count,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGrid({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utiliser LayoutBuilder pour déterminer la largeur disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          // 4 colonnes
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: children,
          );
        } else if (constraints.maxWidth > 800) {
          // 2 colonnes
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: children,
          );
        } else {
          // 1 colonne
          return Column(
            children: children
                .map((child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: child,
            ))
                .toList(),
          );
        }
      },
    );
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartCard({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 400,
        height: 300,
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class DemandesLineChart extends StatelessWidget {
  final List<dynamic> demandes;

  const DemandesLineChart({Key? key, required this.demandes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Générer des données fictives pour le graphique linéaire
    // Vous devrez adapter cela en fonction de vos données réelles
    List<FlSpot> spots = demandes.asMap().entries.map((entry) {
      int month = entry.key + 1;
      int count = entry.value['count'] ?? 0;
      return FlSpot(month.toDouble(), count.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ];
                if (value.toInt() < 1 || value.toInt() > 12) return Container();
                return Text(months[value.toInt() - 1],
                    style: GoogleFonts.montserrat(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(),
                    style: GoogleFonts.montserrat(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 1,
        maxX: 12,
        minY: 0,
        maxY: demandes.isNotEmpty
            ? demandes.map((d) => (d['count'] ?? 0)).reduce((a, b) => a > b ? a : b) + 10
            : 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class OffresPieChart extends StatelessWidget {
  final int demandesCount;
  final int offresCount;

  const OffresPieChart({
    Key? key,
    required this.demandesCount,
    required this.offresCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = (demandesCount + offresCount) as double;
    double demandesPercentage =
    total > 0 ? (demandesCount / total) * 100 : 0;
    double offresPercentage = total > 0 ? (offresCount / total) * 100 : 0;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: offresCount.toDouble(),
            title: 'Offres (${offresPercentage.toStringAsFixed(1)}%)',
            radius: 50,
            titleStyle: GoogleFonts.montserrat(
                fontSize: 12, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.blue,
            value: demandesCount.toDouble(),
            title: 'Demandes (${demandesPercentage.toStringAsFixed(1)}%)',
            radius: 50,
            titleStyle: GoogleFonts.montserrat(
                fontSize: 12, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

class DemandesList extends StatelessWidget {
  final List<dynamic> demandes;
  final Function(int) onDelete;

  const DemandesList({
    Key? key,
    required this.demandes,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Liste des Demandes",
          style: GoogleFonts.montserrat(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        demandes.isEmpty
            ? Center(
          child: Text(
            "Aucune demande trouvée.",
            style: GoogleFonts.montserrat(
                fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: demandes.length,
          itemBuilder: (context, index) {
            final demande = demandes[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(demande['id'].toString(),
                      style: const TextStyle(
                          color: Colors.white)),
                ),
                title: Text(demande['description'],
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                subtitle: Text("Valeur : ${demande['value']}",
                    style: GoogleFonts.montserrat(fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDelete(context, demande['id']),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content:
          const Text("Êtes-vous sûr de vouloir supprimer cette demande ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Supprimer",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(id);
              },
            ),
          ],
        );
      },
    );
  }
}

class OffresList extends StatelessWidget {
  final List<dynamic> offres;
  final Function(int) onDelete;

  const OffresList({
    Key? key,
    required this.offres,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Liste des Offres",
          style: GoogleFonts.montserrat(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        offres.isEmpty
            ? Center(
          child: Text(
            "Aucune offre trouvée.",
            style: GoogleFonts.montserrat(
                fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offres.length,
          itemBuilder: (context, index) {
            final offre = offres[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(offre['id'].toString(),
                      style: const TextStyle(
                          color: Colors.white)),
                ),
                title: Text(offre['description'],
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                subtitle: Text("Tarif : ${offre['tarif']}",
                    style: GoogleFonts.montserrat(fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDelete(context, offre['id']),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content:
          const Text("Êtes-vous sûr de vouloir supprimer cette offre ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Supprimer",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(id);
              },
            ),
          ],
        );
      },
    );
  }
}
