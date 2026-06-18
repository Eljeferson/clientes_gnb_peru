import 'package:flutter/material.dart';
import '../theme.dart';
import '../state_holder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState state = AppState();

  Widget _buildWelcomeHeader(BuildContext context) {
    final syncStr = "${state.lastSyncTime.hour.toString().padLeft(2, '0')}:${state.lastSyncTime.minute.toString().padLeft(2, '0')}";
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GnbColors.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: GnbColors.verdeBotonForest.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PORTAL OFICIAL GNB",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: GnbColors.grisSage,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.shortName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: GnbColors.verdeBosqueOscuro,
                    ),
                  ),
                ],
              ),
              // Circular GNB brand badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GnbColors.verdeSage,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.park_rounded,
                    color: GnbColors.verdeBotonForest,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: GnbColors.bordeSuave),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 16, color: GnbColors.grisSage),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Última Sincronización",
                          style: TextStyle(fontSize: 9, color: GnbColors.grisSage, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Hoy, $syncStr",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 16, color: GnbColors.grisSage),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Registro Fuerza Ventas",
                          style: TextStyle(fontSize: 9, color: GnbColors.grisSage, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          state.advisorCode,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GnbColors.verdeBotonForest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: GnbColors.verdeBotonForest.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "DESEMPEÑO MENSUAL",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: GnbColors.verdeGNB.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${(state.goalPercentage * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Créditos Colocados (Transmitidos)",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "S/ ${state.totalPlacedCredit.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "/ Meta S/ ${state.monthlyGoal.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.goalPercentage,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.15),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Colocaciones Activas: ${state.creditApplications.where((a) => a.status == 'Transmitido').length}",
                style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const Text(
                "SBS Autorizado",
                style: TextStyle(fontSize: 9, color: Colors.white60, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardShortcuts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            "Operaciones Rápidas",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: GnbColors.verdeBosqueOscuro,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildShortcutItem(
                icon: Icons.people_rounded,
                title: "Mi Cartera",
                desc: "Assigned Clients",
                color: GnbColors.azulGNB,
                onTap: () {
                  // Switch to CarteraScreen tab (index 1)
                  final scaffold = context.findAncestorStateOfType<State<StatefulWidget>>();
                  if (scaffold != null && scaffold.toString().contains('AppScaffoldState')) {
                    // Call tab index switcher
                    (scaffold as dynamic).setState(() {
                      (scaffold as dynamic)._currentIndex = 1;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShortcutItem(
                icon: Icons.security_rounded,
                title: "Infocorp Score",
                desc: "Credit ratings",
                color: GnbColors.verdeOscuro,
                onTap: () {
                  // Switch to HistorialScreen tab (index 2)
                  final scaffold = context.findAncestorStateOfType<State<StatefulWidget>>();
                  if (scaffold != null && scaffold.toString().contains('AppScaffoldState')) {
                    (scaffold as dynamic).setState(() {
                      (scaffold as dynamic)._currentIndex = 2;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildShortcutItem(
                icon: Icons.sync_rounded,
                title: "Sincronizar",
                desc: "Offline Tables",
                color: GnbColors.naranjaGNB,
                onTap: () {
                  // Switch to SyncScreen tab (index 3)
                  final scaffold = context.findAncestorStateOfType<State<StatefulWidget>>();
                  if (scaffold != null && scaffold.toString().contains('AppScaffoldState')) {
                    (scaffold as dynamic).setState(() {
                      (scaffold as dynamic)._currentIndex = 3;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShortcutItem(
                icon: Icons.camera_alt_rounded,
                title: "Nueva Captura",
                desc: "In-field Credit",
                color: const Color(0xFF73B51A),
                onTap: () {
                  // Switch to NuevaSolicitudScreen tab (index 4)
                  final scaffold = context.findAncestorStateOfType<State<StatefulWidget>>();
                  if (scaffold != null && scaffold.toString().contains('AppScaffoldState')) {
                    (scaffold as dynamic).setState(() {
                      (scaffold as dynamic)._currentIndex = 4;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutItem({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GnbColors.bordeSuave),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: GnbColors.verdeBosqueOscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: GnbColors.grisSage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            "Bitácora de Actividad",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: GnbColors.verdeBosqueOscuro,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.activities.length,
          itemBuilder: (context, index) {
            final act = state.activities[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GnbColors.bordeSuave),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: act.title.contains("Exitosa") || act.title.contains("Sincronización")
                          ? GnbColors.verdeExito
                          : act.title.contains("Borrador")
                              ? GnbColors.naranjaGNB
                              : GnbColors.azulGNB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: GnbColors.verdeBosqueOscuro,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          act.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: GnbColors.grisSage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    act.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Header Card ──
          _buildWelcomeHeader(context),
          const SizedBox(height: 24),

          // ── Placed Credit / Goals Card ──
          _buildGoalStatusCard(),
          const SizedBox(height: 28),

          // ── Operations Shortcuts ──
          _buildDashboardShortcuts(context),
          const SizedBox(height: 28),

          // ── Recent Activities Feed ──
          _buildRecentActivities(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
