import 'package:flutter/material.dart';
import '../theme.dart';
import '../state_holder.dart';
import '../components/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AppState state = AppState();
  final _formKey = GlobalKey<FormState>();

  String _usuario = "b8a8b13c-7033-4f9e-a1fb-26e1d2c67623"; // Asesor Principal (Tú - App Flutter)
  bool _isLoading = false;
  String _errorMessage = "";

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = "";
      });

      // Simulating secure sales force login delay
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Set state values
        state.currentUserEmail = _usuario.trim();
        state.initDefaultData(); // Reset simulated databases
        state.syncFromSupabase(); // Fetch real data for this UUID

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AppScaffold(),
          ),
        );
      });
    }
  }

  Widget _buildGnbLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Green rounded box with white tree matching the user's image!
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF73B51A), // Brand GNB Green
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.park_rounded, // Majestic White Tree
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "VENTAS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: GnbColors.verdeBotonForest,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              "GNB PERÚ",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 3.5,
                height: 0.9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvisorAlerts() {
    final alerts = [
      {
        "title": "Campaña Consumo GNB",
        "desc": "Tasa especial de 12.5% TEA para clientes en Clasificación Normal Sentinel. Validez hasta fin de mes.",
        "icon": Icons.campaign_rounded,
        "color": GnbColors.azulGNB,
      },
      {
        "title": "Actualización en la Nube",
        "desc": "Su cartera de clientes asignada y calificaciones crediticias se actualizan de forma automática en tiempo real con el servidor de Supabase.",
        "icon": Icons.cloud_done_rounded,
        "color": GnbColors.azulGNB,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            "Boletines Fuerza de Ventas",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: GnbColors.verdeBosqueOscuro,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...alerts.map((al) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GnbColors.bordeSuave),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (al["color"] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    al["icon"] as IconData,
                    color: al["color"] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        al["title"] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: GnbColors.verdeBosqueOscuro,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        al["desc"] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: GnbColors.grisSage,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GnbColors.fondoCrema,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Centered Logo ──
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: _buildGnbLogo(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Login Card (Usuario only) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: GnbColors.bordeSuave),
                    boxShadow: [
                      BoxShadow(
                        color: GnbColors.verdeBotonForest.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Acceso Asesores GNB",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GnbColors.verdeBosqueOscuro,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "Captura de solicitudes y gestión de cartera en campo",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: GnbColors.grisSage,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username (Advisor Code) Input
                        TextFormField(
                          initialValue: _usuario,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(
                            color: GnbColors.verdeBosqueOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: const InputDecoration(
                            labelText: "Código de Asesor",
                            prefixIcon: Icon(Icons.badge_outlined, color: GnbColors.verdeBotonForest),
                            hintText: "Ej. ASESOR990 o gbenavides",
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Ingrese su código de asesor";
                            }
                            if (val.trim().length < 4) {
                              return "El código debe tener mínimo 4 caracteres";
                            }
                            return null;
                          },
                          onChanged: (val) => _usuario = val,
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: GnbColors.rojoError,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GnbColors.verdeBotonForest,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "INGRESAR AL PORTAL",
                                    style: TextStyle(letterSpacing: 0.5, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Advisor News ──
                _buildAdvisorAlerts(),
                const SizedBox(height: 24),

                // ── Support Footer ──
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Soporte TI Asesores: (01) 616-4722 - Anexo 450",
                        style: TextStyle(
                          fontSize: 11,
                          color: GnbColors.grisSage,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "VENTAS GNB v3.4.0 (Conectado - Servidores GNB)",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
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
