import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state_holder.dart';
import 'package:signature/signature.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({super.key});

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  final AppState state = AppState();

  // Wizard variables
  int _currentStep = 0; // 0: Cliente, 1: Condiciones, 2: Fotos, 3: Transmision/Exito
  
  // Paso 1 variables
  Client? _selectedClient;
  bool _isNewClient = false;
  final _newDniController = TextEditingController();
  final _newNameController = TextEditingController();

  // Paso 2 variables
  String _productType = "Consumo";
  double _amount = 10000.00;
  int _term = 24;
  double _income = 3500.00;

  // Paso 3 variables (Photos)
  bool _hasPhotoDni = false;
  bool _hasPhotoUtility = false;
  bool _hasPhotoIncome = false;
  
  // Camera Simulator variables
  bool _isCameraActive = false;
  String _activePhotoType = ""; // "DNI", "Recibo", "Ingresos"
  bool _isProcessingPhoto = false;

  // Signature variables
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _hasSignature = false;

  // Paso 4 variables (Transmission)
  bool _isTransmitting = false;
  CreditApplication? _createdApplication;

  @override
  void initState() {
    super.initState();
    // Prepopulate with first client by default
    if (state.assignedPortfolio.isNotEmpty) {
      _selectedClient = state.assignedPortfolio[0];
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_isNewClient) {
        if (_newDniController.text.trim().length != 8) {
          _showError("El DNI debe tener 8 dígitos");
          return;
        }
        if (_newNameController.text.trim().isEmpty) {
          _showError("Ingrese el nombre completo del cliente");
          return;
        }
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_income <= 0) {
        _showError("Ingrese un sustento de ingresos mensuales válido");
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (!_hasPhotoDni || !_hasPhotoUtility || !_hasPhotoIncome) {
        _showError("Debe capturar la foto de todos los 3 documentos para el expediente digital SBS");
        return;
      }
      if (_signatureController.isEmpty) {
        _showError("El cliente debe firmar la solicitud");
        return;
      }
      setState(() => _hasSignature = true);
      // Trigger electronic transmission automatically on next
      _transmitirSolicitud();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: GnbColors.rojoError),
    );
  }

  // Camera Viewfinder Trigger
  void _openCamera(String type) {
    setState(() {
      _isCameraActive = true;
      _activePhotoType = type;
      _isProcessingPhoto = false;
    });
  }

  void _capturePhoto() {
    setState(() {
      _isProcessingPhoto = true;
    });

    // Simulate OCR & image processing SBS rules (800ms)
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isCameraActive = false;
        _isProcessingPhoto = false;
        if (_activePhotoType == "DNI") {
          _hasPhotoDni = true;
        } else if (_activePhotoType == "Recibo") {
          _hasPhotoUtility = true;
        } else if (_activePhotoType == "Ingresos") {
          _hasPhotoIncome = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Imagen $_activePhotoType procesada con éxito y firmada digitalmente."),
          backgroundColor: GnbColors.verdeExito,
        ),
      );
    });
  }

  void _transmitirSolicitud() {
    setState(() {
      _currentStep = 3;
      _isTransmitting = true;
    });

    // Simulate electronic transmission layers (1800ms)
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      final clientDni = _isNewClient ? _newDniController.text.trim() : _selectedClient!.dni;
      final clientName = _isNewClient ? _newNameController.text.trim() : _selectedClient!.nombre;
      
      // Si el cliente ya tenía una solicitud previa (ej. creada en Android y asignada en Web)
      String targetId = "SOL-${10000 + math.Random().nextInt(89999)}";
      try {
        final existingApp = state.creditApplications.firstWhere(
          (a) => a.clientDni == clientDni && (a.status == "NUEVA_SOLICITUD" || a.status == "enviado" || a.status == "Borrador")
        );
        targetId = existingApp.id; // ¡Reutilizar el mismo ID para actualizar la solicitud real!
      } catch (_) {}

      if (_isNewClient) {
        // Link to local portfolio too!
        state.addNewClient(Client(
          dni: clientDni,
          nombre: clientName,
          telefono: "987654321",
          direccion: "Dirección ingresada de campo",
          sentinelRating: "Normal",
          sentinelScore: 710,
          deudaTotal: 0.0,
          isSync: false, // requires upload sync!
        ));
      }

      final app = CreditApplication(
        id: targetId,
        clientDni: clientDni,
        clientName: clientName,
        productType: _productType,
        amount: _amount,
        term: _term,
        income: _income,
        documentPhotosCount: 3,
        status: "recibido_comite",
        date: DateTime.now().toString().substring(0, 16),
      );

      state.addApplication(app);

      setState(() {
        _isTransmitting = false;
        _createdApplication = app;
      });
    });
  }

  void _resetWizard() {
    setState(() {
      _currentStep = 0;
      _isNewClient = false;
      _newDniController.clear();
      _newNameController.clear();
      _productType = "Consumo";
      _amount = 10000.00;
      _term = 24;
      _income = 3500.00;
      _hasPhotoDni = false;
      _hasPhotoUtility = false;
      _hasPhotoIncome = false;
      _createdApplication = null;
    });
  }

  // ── STEP 1: CLIENT SELECTION ──
  Widget _buildStepClient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selección del Solicitante",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
        ),
        const SizedBox(height: 6),
        const Text(
          "Vincule la solicitud a un cliente de su cartera asignada o ingrese los datos de un nuevo cliente prospectado en campo.",
          style: TextStyle(fontSize: 11, color: GnbColors.grisSage, height: 1.3),
        ),
        const SizedBox(height: 20),

        // Portfolio Selection Radio row
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isNewClient = false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: !_isNewClient ? GnbColors.verdeSage : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: !_isNewClient ? GnbColors.verdeBotonForest : GnbColors.bordeSuave),
                  ),
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isNewClient,
                        activeColor: GnbColors.verdeBotonForest,
                        onChanged: (val) => setState(() => _isNewClient = false),
                      ),
                      const Expanded(
                        child: Text(
                          "En Cartera",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isNewClient = true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _isNewClient ? GnbColors.verdeSage : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _isNewClient ? GnbColors.verdeBotonForest : GnbColors.bordeSuave),
                  ),
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _isNewClient,
                        activeColor: GnbColors.verdeBotonForest,
                        onChanged: (val) => setState(() => _isNewClient = true),
                      ),
                      const Expanded(
                        child: Text(
                          "Nuevo Cliente",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (!_isNewClient) ...[
          // Portfolio drop-down
          const Text(
            "Seleccionar de Cartera Asignada:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: GnbColors.bordeSuave),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Client>(
                value: _selectedClient,
                isExpanded: true,
                onChanged: (Client? val) {
                  setState(() {
                    _selectedClient = val;
                  });
                },
                items: state.assignedPortfolio.map((client) {
                  return DropdownMenuItem<Client>(
                    value: client,
                    child: Text(
                      "${client.nombre} (DNI ${client.dni})",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ] else ...[
          // New Client fields
          const Text(
            "Datos de Prospecto Nuevo:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newDniController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: const InputDecoration(
              labelText: "DNI de Prospecto",
              counterText: "",
              prefixIcon: Icon(Icons.badge_outlined, color: GnbColors.verdeBotonForest),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newNameController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: "Nombres Completos",
              prefixIcon: Icon(Icons.person_outline_rounded, color: GnbColors.verdeBotonForest),
            ),
          ),
        ],
      ],
    );
  }

  // ── STEP 2: LOAN CONDITIONS ──
  Widget _buildStepConditions() {
    double monthlyInstallment = (_amount * 1.14) / _term;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Condiciones de Crédito",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
        ),
        const SizedBox(height: 20),

        // Product Selection dropdown
        const Text(
          "Producto Financiero:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: GnbColors.bordeSuave),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _productType,
              isExpanded: true,
              onChanged: (String? val) {
                setState(() {
                  _productType = val!;
                });
              },
              items: ["Consumo", "Microempresa", "Hipotecario"].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Amount requested
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Monto Solicitado:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
            ),
            Text(
              "S/ ${_amount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GnbColors.azulGNB),
            ),
          ],
        ),
        Slider(
          value: _amount,
          min: 1000,
          max: _productType == "Consumo"
              ? 50000
              : _productType == "Microempresa"
                  ? 100000
                  : 250000,
          divisions: 99,
          activeColor: GnbColors.azulGNB,
          inactiveColor: GnbColors.bordeSuave,
          onChanged: (val) {
            setState(() {
              _amount = val;
            });
          },
        ),

        // Term in months
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Plazo de Amortización:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
            ),
            Text(
              "$_term Meses",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GnbColors.azulGNB),
            ),
          ],
        ),
        Slider(
          value: _term.toDouble(),
          min: 6,
          max: _productType == "Hipotecario" ? 120 : 60,
          divisions: _productType == "Hipotecario" ? 19 : 9,
          activeColor: GnbColors.azulGNB,
          inactiveColor: GnbColors.bordeSuave,
          onChanged: (val) {
            setState(() {
              _term = val.toInt();
            });
          },
        ),
        const SizedBox(height: 12),

        // Income field
        TextFormField(
          initialValue: _income.toStringAsFixed(0),
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
          decoration: const InputDecoration(
            labelText: "Sustento de Ingreso Mensual Neto",
            prefixText: "S/ ",
            prefixIcon: Icon(Icons.money_outlined, color: GnbColors.verdeBotonForest),
          ),
          onChanged: (val) {
            setState(() {
              _income = double.tryParse(val) ?? 0.0;
            });
          },
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // Monthly Installment calculation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Cuota Mensual Estimada:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
            ),
            Text(
              "S/ ${monthlyInstallment.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GnbColors.verdeExito),
            ),
          ],
        ),
      ],
    );
  }

  // ── STEP 3: DOCUMENT SCAN PHOTO ──
  Widget _buildStepPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Captura de Expediente Digital",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
        ),
        const SizedBox(height: 6),
        const Text(
          "Fotografíe y suba de forma segura los documentos SBS exigidos para el análisis de riesgos.",
          style: TextStyle(fontSize: 11, color: GnbColors.grisSage, height: 1.3),
        ),
        const SizedBox(height: 20),

        _buildPhotoTile("Foto de DNI de Cliente", _hasPhotoDni, () => _openCamera("DNI")),
        _buildPhotoTile("Recibo de Servicios (Luz/Agua)", _hasPhotoUtility, () => _openCamera("Recibo")),
        _buildPhotoTile("Sustento de Ingresos (Boletas)", _hasPhotoIncome, () => _openCamera("Ingresos")),
        
        const SizedBox(height: 16),
        const Text(
          "Firma Digital del Solicitante:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: GnbColors.bordeSuave),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _signatureController.clear(),
            icon: const Icon(Icons.clear, size: 16, color: GnbColors.rojoError),
            label: const Text("Borrar Firma", style: TextStyle(color: GnbColors.rojoError, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoTile(String label, bool isCaptured, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GnbColors.bordeSuave),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCaptured ? GnbColors.verdeSage : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCaptured ? Icons.check_circle_outline_rounded : Icons.photo_camera_outlined,
              color: isCaptured ? GnbColors.verdeExito : GnbColors.grisSage,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GnbColors.verdeBosqueOscuro),
                ),
                Text(
                  isCaptured ? "Documento digitalizado con éxito" : "Requiere foto para expediente",
                  style: TextStyle(fontSize: 10, color: isCaptured ? GnbColors.grisSage : GnbColors.naranjaGNB, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 32),
              backgroundColor: isCaptured ? GnbColors.verdeSage : GnbColors.azulGNB,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isCaptured ? "REPETIR" : "TOMAR",
              style: TextStyle(fontSize: 10, color: isCaptured ? GnbColors.verdeBotonForest : Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── CAMERA SCANNER VIEWVIEWVIEW VIEWFINDER SIMULATOR OVERLAY ──
  Widget _buildCameraViewfinder() {
    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Stack(
        children: [
          // ── Centered camera frame boundary overlay ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 190,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isProcessingPhoto ? GnbColors.naranjaGNB : const Color(0xFF73B51A),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isProcessingPhoto
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(color: GnbColors.naranjaGNB),
                              SizedBox(height: 12),
                              Text(
                                "PROCESANDO IMAGEN SBS...",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          )
                        : Text(
                            "ALINEE EL DOCUMENTO AHORA\n($_activePhotoType)",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Evite reflejos y sombras. Certificado SBS Cifrado.",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),

          // Top Header options
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CÁMARA DIGITALIZADORA",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_off_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Bottom Capture Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: _isProcessingPhoto ? null : () => setState(() => _isCameraActive = false),
                  child: const Text("CANCELAR", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ),
                // Shutter Button
                InkWell(
                  onTap: _isProcessingPhoto ? null : _capturePhoto,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 80), // Balance spatial gap
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 4: RISK TRANSMISSION LOADING SCREEN ──
  Widget _buildStepTransmitting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: GnbColors.azulGNB),
            const SizedBox(height: 24),
            Text(
              "FIRMANDO Y ENCRIPTANDO EXPEDIENTE...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
            ),
            SizedBox(height: 8),
            Text(
              "Transmitiendo de forma segura al departamento de Riesgos del Banco GNB Perú S.A.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: GnbColors.grisSage, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 4: SUCCESS PDF VOUCHER RECEIPT ──
  Widget _buildStepSuccess() {
    if (_createdApplication == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: GnbColors.verdeSageOscuro.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: GnbColors.verdeExito.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Success Tick Circle Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF1E7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: GnbColors.verdeExito,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "TRANSMISIÓN ELECTRÓNICA EXITOSA",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: GnbColors.verdeBosqueOscuro),
              ),
              const SizedBox(height: 4),
              const Text(
                "CONSTANCIA DE EXPEDIENTE DIGITAL",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GnbColors.grisSage, letterSpacing: 1.0),
              ),
              const SizedBox(height: 20),
              const Divider(color: GnbColors.bordeSuave),
              const SizedBox(height: 12),

              // Digital Voucher Info
              _buildVoucherRow("Código Único", _createdApplication!.id),
              _buildVoucherRow("Asesor Remitente", state.advisorCode),
              _buildVoucherRow("Fecha Transmisión", _createdApplication!.date),
              _buildVoucherRow("Cliente DNI", "${_createdApplication!.clientName} (${_createdApplication!.clientDni})"),
              _buildVoucherRow("Tipo de Crédito", _createdApplication!.productType),
              _buildVoucherRow("Monto Solicitado", "S/ ${_createdApplication!.amount.toStringAsFixed(2)}"),
              _buildVoucherRow("Plazo Aprobado", "${_createdApplication!.term} Meses"),
              _buildVoucherRow("Estatus SBS", "EN EVALUACIÓN - RIESGOS"),
              
              const SizedBox(height: 24),
              const Divider(color: GnbColors.bordeSuave),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Imprimiendo constancia digital... (PDF descargado en descargas/GNB_VENTAS)"),
                            backgroundColor: GnbColors.azulGNB,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text("VOUCHER PDF", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetWizard,
                      style: ElevatedButton.styleFrom(backgroundColor: GnbColors.verdeBotonForest),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text("NUEVA CAPTURA", style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 11, color: GnbColors.grisSage, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: key == "Estatus SBS" ? GnbColors.verdeExito : GnbColors.verdeBosqueOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraActive) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildCameraViewfinder(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step Indicator header ──
          if (_currentStep < 3) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GnbColors.bordeSuave),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepBubble(0, "Cliente"),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: GnbColors.grisSage),
                  _buildStepBubble(1, "Crédito"),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: GnbColors.grisSage),
                  _buildStepBubble(2, "Expediente"),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Active step content ──
          if (_currentStep == 0) _buildStepClient(),
          if (_currentStep == 1) _buildStepConditions(),
          if (_currentStep == 2) _buildStepPhotos(),
          if (_currentStep == 3 && _isTransmitting) _buildStepTransmitting(),
          if (_currentStep == 3 && !_isTransmitting) _buildStepSuccess(),

          const SizedBox(height: 28),

          // ── Bottom wizard navigation buttons ──
          if (_currentStep < 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _prevStep,
                    child: const Text("ATRÁS"),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(_currentStep == 2 ? "TRANSMITIR SOLICITUD" : "SIGUIENTE"),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStepBubble(int stepNum, String label) {
    final isActive = _currentStep == stepNum;
    final isDone = _currentStep > stepNum;
    
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone
                ? GnbColors.verdeExito
                : isActive
                    ? GnbColors.verdeBotonForest
                    : GnbColors.bordeSuave,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : Text(
                    "${stepNum + 1}",
                    style: TextStyle(
                      color: isActive ? Colors.white : GnbColors.grisSage,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? GnbColors.verdeBosqueOscuro : GnbColors.grisSage,
          ),
        ),
      ],
    );
  }
}
