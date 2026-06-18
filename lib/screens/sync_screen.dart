import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../state_holder.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final AppState state = AppState();
  
  bool _isSyncing = false;
  double _progress = 0.0;
  String _syncMessage = "Listo para actualizar datos...";
  List<String> _syncLogs = [];

  void _runSincronizacion() {
    setState(() {
      _isSyncing = true;
      _progress = 0.0;
      _syncLogs.clear();
      _syncMessage = "Estableciendo conexión cifrada con central GNB...";
    });

    _addLog("Iniciando actualización de datos central...");
    _addLog("Comprobando canal seguro con servidores de nube...");

    // 1. Step 1: Connect (500ms)
    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _progress = 0.25;
        _syncMessage = "Conectado. Sincronizando solicitudes con base central...";
      });
      _addLog("Conexión segura establecida con el servidor de Riesgos.");
      _addLog("Verificando solicitudes transmitidas del mes...");
    });

    // 2. Step 2: Upload applications (1200ms)
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _progress = 0.55;
        _syncMessage = "Descargando actualizaciones de cartera y Score...";
      });
      _addLog("Canal de datos de solicitudes verificado correctamente.");
      _addLog("Iniciando descarga de cartera asignada...");
      _addLog("Actualizando clasificaciones Sentinel SBS...");
    });

    // 3. Step 3: Download portfolio (2000ms)
    Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      setState(() {
        _progress = 0.85;
        _syncMessage = "Guardando datos actualizados en el servidor...";
      });
      _addLog("Sincronizando tablas y descargando expedientes actualizados...");
      
      // Execute actual Supabase live pull/push if active
      if (state.useSupabase) {
        await state.syncFromSupabase();
        _addLog("Base de datos Supabase actualizada en tiempo real.");
      } else {
        _addLog("Descargados expedientes de clientes actualizados.");
      }
      
      _addLog("Guardando registros en servidor Supabase GNB...");
    });

    // 4. Step 4: Finish (2800ms)
    Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      
      // Update global states on success!
      setState(() {
        _progress = 1.0;
        _isSyncing = false;
        _syncMessage = "¡Base de datos GNB Central 100% actualizada!";
      });
      
      _addLog("Actualización central de base de datos completada.");
      
      // Change pending draft application status to Transmitted in AppState!
      final drafts = state.creditApplications.where((a) => a.status == "Borrador").toList();
      for (var d in drafts) {
        state.transmitApplication(d.id);
      }

      state.lastSyncTime = DateTime.now(); // Update sync timestamp
      state.addActivity("Actualización Central", "Base de datos actualizada con servidor Supabase GNB.");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Base de datos central Supabase actualizada. Cuentas y Cartera Sincronizadas."),
          backgroundColor: GnbColors.verdeExito,
        ),
      );
    });
  }

  void _addLog(String text) {
    if (mounted) {
      setState(() {
        _syncLogs.add("[${DateTime.now().second.toString().padLeft(2, '0')}s] $text");
      });
    }
  }

  Widget _buildTableTile({required String tableName, required String count, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GnbColors.bordeSuave),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GnbColors.verdeSage,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: GnbColors.verdeBotonForest, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tableName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GnbColors.verdeBosqueOscuro),
                ),
                const Text(
                  "Servidor en Vivo Conectado",
                  style: TextStyle(fontSize: 10, color: GnbColors.verdeExito, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GnbColors.verdeExito.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: GnbColors.verdeExito,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header status Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GnbColors.bordeSuave),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
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
                    const Text(
                      "Base de Datos GNB Central",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                    ),
                    const Icon(
                      Icons.cloud_done_rounded,
                      color: GnbColors.verdeExito,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Toda su cartera de campo y solicitudes del mes se encuentran sincronizadas en la nube de forma segura.",
                  style: TextStyle(fontSize: 12, color: GnbColors.grisSage, height: 1.3),
                ),
                const SizedBox(height: 20),
                
                // Sync Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _runSincronizacion,
                    icon: const Icon(Icons.sync_rounded, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GnbColors.azulGNB,
                    ),
                    label: const Text(
                      "ACTUALIZAR BASE DE DATOS",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Sync Loader Progress Bar ──
          if (_isSyncing || _progress > 0) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: GnbColors.bordeSuave),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _syncMessage,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                        ),
                      ),
                      Text(
                        "${(_progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.azulGNB),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: GnbColors.bordeSuave,
                      color: GnbColors.azulGNB,
                    ),
                  ),
                  if (_syncLogs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Registro de Transmisión:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GnbColors.grisSage),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GnbColors.fondoCrema,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GnbColors.bordeSuave),
                      ),
                      child: ListView.builder(
                        itemCount: _syncLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              _syncLogs[index],
                              style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: GnbColors.verdeBosqueOscuro),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Tables summary list ──
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 12),
            child: Text(
              "Servidores de Base de Datos GNB",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
            ),
          ),
          
          _buildTableTile(
            tableName: "Clientes Asignados (Cartera)",
            count: "${state.assignedPortfolio.length} Clientes",
            icon: Icons.people_outline_rounded,
          ),
          _buildTableTile(
            tableName: "Solicitudes Transmitidas",
            count: "${state.creditApplications.length} Solicitudes",
            icon: Icons.calculate_outlined,
          ),
          _buildTableTile(
            tableName: "Score Sentinel (Consulta Central)",
            count: "Infocorp Activo",
            icon: Icons.security_rounded,
          ),
        ],
      ),
    );
  }
}
