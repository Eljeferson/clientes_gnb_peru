import 'package:flutter/material.dart';
import '../theme.dart';
import '../state_holder.dart';
import '../screens/home_screen.dart';
import '../screens/cartera_screen.dart';
import '../screens/nueva_solicitud_screen.dart';
import '../screens/historial_screen.dart';
import '../screens/sync_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final AppState state = AppState();
  int _currentIndex = 0;

  // Track active sub-view
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const CarteraScreen(),
      const HistorialScreen(),
      const SyncScreen(),
      const NuevaSolicitudScreen(), // Index 4 accessed via FAB or direct
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context); // Close Drawer if open
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine active screen
    Widget activeScreen = _screens[_currentIndex];

    // Format last sync time string
    final syncStr = "${state.lastSyncTime.hour.toString().padLeft(2, '0')}:${state.lastSyncTime.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: GnbColors.fondoCrema,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? "GNB VENTAS"
              : _currentIndex == 1
                  ? "Mi Cartera"
                  : _currentIndex == 2
                      ? "Score Sentinel"
                      : _currentIndex == 3
                          ? "Base de Datos"
                          : "Captura de Crédito",
        ),
        actions: [
          // Quick Sync Status Indicator
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: const [
                Icon(
                  Icons.cloud_done_rounded,
                  color: GnbColors.verdeExito,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  "Conectado",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: GnbColors.verdeExito,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: GnbColors.fondoCrema,
        child: Column(
          children: [
            // ── Drawer Header ──
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: GnbColors.verdeBotonForest,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: GnbColors.blancoPuro,
                child: const Icon(
                  Icons.park_rounded,
                  color: GnbColors.verdeGNB,
                  size: 40,
                ),
              ),
              accountName: Text(
                state.shortName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                "Asesor ID: ${state.advisorCode} • Sync: $syncStr",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // ── Drawer items ──
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: GnbColors.verdeBotonForest),
              title: const Text("Dashboard Principal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              selected: _currentIndex == 0,
              onTap: () => _navigateToScreen(0),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded, color: GnbColors.verdeBotonForest),
              title: const Text("Gestión de Cartera", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              selected: _currentIndex == 1,
              onTap: () => _navigateToScreen(1),
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined, color: GnbColors.verdeBotonForest),
              title: const Text("Nueva Solicitud de Campo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              selected: _currentIndex == 4,
              onTap: () => _navigateToScreen(4),
            ),
            ListTile(
              leading: const Icon(Icons.security_rounded, color: GnbColors.verdeBotonForest),
              title: const Text("Consulta Historial Crediticio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              selected: _currentIndex == 2,
              onTap: () => _navigateToScreen(2),
            ),
            ListTile(
              leading: const Icon(Icons.sync_rounded, color: GnbColors.verdeBotonForest),
              title: const Text("Base de Datos Central", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              selected: _currentIndex == 3,
              onTap: () => _navigateToScreen(3),
            ),
            const Divider(color: GnbColors.bordeSuave),
            
            // ── Placed Credit Progress Card in Drawer ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GnbColors.bordeSuave),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Meta de Colocación",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GnbColors.grisSage),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "S/ ${state.totalPlacedCredit.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: GnbColors.verdeBosqueOscuro),
                        ),
                        Text(
                          "Meta: S/ ${state.monthlyGoal.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 10, color: GnbColors.grisSage),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.goalPercentage,
                        minHeight: 6,
                        backgroundColor: GnbColors.bordeSuave,
                        color: GnbColors.verdeGNB,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(state.goalPercentage * 100).toStringAsFixed(1)}% completado este mes",
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: GnbColors.verdeBotonForest),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            
            // ── Logout ──
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: GnbColors.rojoError),
              title: const Text("Cerrar Sesión", style: TextStyle(color: GnbColors.rojoError, fontWeight: FontWeight.bold, fontSize: 13)),
              onTap: () {
                state.resetState();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: activeScreen,
      
      // ── Central Capture Floating Action Button ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTabTapped(4),
        backgroundColor: const Color(0xFF73B51A), // Official green GNB
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // ── Spacious Advisor Bottom Bar ──
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomTab(
                index: 0,
                icon: Icons.dashboard_rounded,
                label: "Inicio",
              ),
              _buildBottomTab(
                index: 1,
                icon: Icons.people_outline_rounded,
                label: "Cartera",
              ),
              const SizedBox(width: 40), // Spacer for Central Docked FAB
              _buildBottomTab(
                index: 2,
                icon: Icons.security_rounded,
                label: "Sentinel",
              ),
              _buildBottomTab(
                index: 3,
                icon: Icons.sync_rounded,
                label: "Sincronizar",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab({required int index, required IconData icon, required String label}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? GnbColors.verdeBotonForest : GnbColors.grisSage,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? GnbColors.verdeBotonForest : GnbColors.grisSage,
            ),
          ),
        ],
      ),
    );
  }
}
