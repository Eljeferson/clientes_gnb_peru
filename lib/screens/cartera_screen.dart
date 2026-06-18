import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state_holder.dart';

class CarteraScreen extends StatefulWidget {
  const CarteraScreen({super.key});

  @override
  State<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends State<CarteraScreen> {
  final AppState state = AppState();
  String _searchQuery = "";
  String _selectedRatingFilter = "Todos";

  Color _getRatingColor(String rating) {
    switch (rating) {
      case "Normal":
        return GnbColors.verdeExito;
      case "CPP":
        return GnbColors.naranjaGNB;
      case "Deficiente":
        return Colors.orange[800]!;
      case "Pérdida":
        return GnbColors.rojoError;
      default:
        return Colors.grey;
    }
  }

  void _showClientDetailsSheet(Client client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: GnbColors.fondoCrema,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GnbColors.bordeSuave,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRatingColor(client.sentinelRating).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: _getRatingColor(client.sentinelRating),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cliente Asignado",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: GnbColors.grisSage,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          client.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GnbColors.verdeBosqueOscuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: GnbColors.bordeSuave),
              const SizedBox(height: 12),
              
              // Client Info Grid
              _buildDetailRow(Icons.badge_outlined, "DNI", client.dni),
              _buildDetailRow(Icons.phone_android_outlined, "Teléfono Celular", client.telefono),
              _buildDetailRow(Icons.location_on_outlined, "Dirección de Campo", client.direccion),
              _buildDetailRow(
                Icons.security_rounded, 
                "Calificación Sentinel", 
                "${client.sentinelRating} (${client.sentinelScore} Pts)",
                textColor: _getRatingColor(client.sentinelRating),
              ),
              _buildDetailRow(Icons.money_off_rounded, "Deuda en el Sistema SBS", "S/ ${client.deudaTotal.toStringAsFixed(2)}"),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Llamando a ${client.nombre}... (Simulación de llamada desde centralita GNB)"),
                            backgroundColor: GnbColors.azulGNB,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: const Text("LLAMAR"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Redirect to NuevaSolicitudScreen with prepopulated client data!
                        final scaffold = context.findAncestorStateOfType<State<StatefulWidget>>();
                        if (scaffold != null && scaffold.toString().contains('AppScaffoldState')) {
                          (scaffold as dynamic).setState(() {
                            (scaffold as dynamic)._currentIndex = 4; // Loan capture index
                          });
                          // Prepopulate inside state or pass parameters
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Solicitud de crédito iniciada para ${client.nombre}."),
                              backgroundColor: GnbColors.verdeBotonForest,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GnbColors.azulGNB,
                      ),
                      icon: const Icon(Icons.add_box_rounded, size: 18, color: Colors.white),
                      label: const Text("SOLICITAR CRÉDITO", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: GnbColors.grisSage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GnbColors.grisSage),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? GnbColors.verdeBosqueOscuro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtered lists
    final filteredClients = state.assignedPortfolio.where((client) {
      final matchesSearch = client.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.dni.contains(_searchQuery);
      final matchesFilter = _selectedRatingFilter == "Todos" || client.sentinelRating == _selectedRatingFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Input ──
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: const InputDecoration(
              labelText: "Buscar cliente por DNI o Nombre",
              prefixIcon: Icon(Icons.search_rounded, color: GnbColors.verdeBotonForest),
            ),
          ),
          const SizedBox(height: 16),

          // ── Filter Chips ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["Todos", "Normal", "CPP", "Deficiente", "Pérdida"].map((rating) {
                final isSelected = _selectedRatingFilter == rating;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      rating,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : GnbColors.verdeBosqueOscuro,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: GnbColors.verdeBotonForest,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : GnbColors.bordeSuave,
                      ),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedRatingFilter = rating;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Total Clients label ──
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              "Clientes Encontrados: ${filteredClients.length}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: GnbColors.grisSage,
              ),
            ),
          ),

          // ── Client Cards List ──
          Expanded(
            child: filteredClients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.people_outline_rounded, size: 48, color: GnbColors.bordeSuave),
                        SizedBox(height: 8),
                        Text(
                          "No se encontraron clientes asignados\ncon los filtros indicados.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: GnbColors.grisSage, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      final c = filteredClients[index];
                      final ratingColor = _getRatingColor(c.sentinelRating);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: GnbColors.bordeSuave),
                        ),
                        child: InkWell(
                          onTap: () => _showClientDetailsSheet(c),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.nombre,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: GnbColors.verdeBosqueOscuro,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "DNI: ${c.dni}",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: GnbColors.grisSage,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Sentinel Risk Rating Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ratingColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: ratingColor.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        "${c.sentinelRating} (${c.sentinelScore})",
                                        style: TextStyle(
                                          color: ratingColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, color: GnbColors.bordeSuave),
                                const SizedBox(height: 12),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.phone_android, size: 14, color: GnbColors.grisSage),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.telefono,
                                      style: const TextStyle(fontSize: 12, color: GnbColors.verdeBosqueOscuro, fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.monetization_on_outlined, size: 14, color: GnbColors.grisSage),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Deuda SBS: S/ ${c.deudaTotal.toStringAsFixed(0)}",
                                      style: const TextStyle(fontSize: 12, color: GnbColors.verdeBosqueOscuro, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: GnbColors.grisSage),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        c.direccion,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: GnbColors.grisSage),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
