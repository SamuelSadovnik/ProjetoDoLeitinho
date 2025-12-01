import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'new_collection_page.dart';

class ScanFarmQrPage extends StatefulWidget {
  final UserModel collector;

  const ScanFarmQrPage({super.key, required this.collector});

  @override
  State<ScanFarmQrPage> createState() => _ScanFarmQrPageState();
}

class _ScanFarmQrPageState extends State<ScanFarmQrPage> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _hasPermission = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Pausar o scanner enquanto processa
    _scannerController?.stop();

    try {
      // Tentar decodificar o QR Code
      // Formatos aceitos:
      // 1. JSON completo da fazenda: {"idfarm": 1, "name": "...", ...}
      // 2. JSON simples: {"farmId": 1} ou {"idfarm": 1}
      // 3. Apenas o ID: "1"

      FarmModel? farm;
      int? farmId;

      // Tentar parse como JSON
      try {
        final jsonData = jsonDecode(code);
        if (jsonData is Map) {
          // Verificar se é o JSON completo da fazenda
          if (jsonData.containsKey('idfarm') && jsonData.containsKey('name')) {
            // É o JSON completo da fazenda - usar diretamente
            farm = FarmModel.fromJson(Map<String, dynamic>.from(jsonData));
          } else if (jsonData.containsKey('farmId')) {
            farmId = jsonData['farmId'] is int
                ? jsonData['farmId']
                : int.tryParse(jsonData['farmId'].toString());
          } else if (jsonData.containsKey('idfarm')) {
            farmId = jsonData['idfarm'] is int
                ? jsonData['idfarm']
                : int.tryParse(jsonData['idfarm'].toString());
          }
        }
      } catch (_) {
        // Se não for JSON, tentar parse como número direto
        farmId = int.tryParse(code);
      }

      // Se já temos a fazenda completa do QR Code
      if (farm != null) {
        if (mounted) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => NewCollectionPage(
                collector: widget.collector,
                preSelectedFarm: farm,
              ),
            ),
          );
          // Se salvou a coleta, voltar para o dashboard com resultado true
          if (result == true && mounted) {
            Navigator.pop(context, true);
          } else {
            // Se voltou sem salvar, reiniciar o scanner
            setState(() {
              _isProcessing = false;
            });
            _scannerController?.start();
          }
        }
        return;
      }

      // Se temos apenas o ID, buscar a fazenda na API
      if (farmId == null) {
        setState(() {
          _errorMessage = 'QR Code inválido. Formato não reconhecido.';
          _isProcessing = false;
        });
        _scannerController?.start();
        return;
      }

      // Buscar a fazenda na API
      final apiService = context.read<ApiService>();
      final response = await apiService.getFarmById(farmId);

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data;
        if (data['success'] == true && data['content'] != null) {
          final farm = FarmModel.fromJson(data['content']);

          if (mounted) {
            // Navegar para o formulário com a fazenda pré-selecionada
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => NewCollectionPage(
                  collector: widget.collector,
                  preSelectedFarm: farm,
                ),
              ),
            );
            // Se salvou a coleta, voltar para o dashboard com resultado true
            if (result == true && mounted) {
              Navigator.pop(context, true);
            } else {
              // Se voltou sem salvar, reiniciar o scanner
              setState(() {
                _isProcessing = false;
              });
              _scannerController?.start();
            }
          }
          return;
        }
      }

      setState(() {
        _errorMessage = 'Fazenda não encontrada. Verifique o QR Code.';
        _isProcessing = false;
      });
      _scannerController?.start();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao processar QR Code: $e';
        _isProcessing = false;
      });
      _scannerController?.start();
    }
  }

  void _goToManualSelection() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NewCollectionPage(collector: widget.collector),
      ),
    );
    // Se salvou a coleta, voltar para o dashboard com resultado true
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Fazenda'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
      ),
      body: Column(
        children: [
          // Área do scanner
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Scanner
                if (_hasPermission)
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return _buildPermissionError(error.errorCode.name);
                    },
                  )
                else
                  _buildPermissionError('Permissão negada'),

                // Overlay com área de scan
                _buildScanOverlay(),

                // Indicador de processamento
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Buscando fazenda...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Área inferior com instruções e botão manual
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  // Mensagem de erro
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Instruções
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aponte a câmera para o QR Code da fazenda',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O QR Code deve estar localizado na entrada da propriedade',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.lightGray),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Botão de seleção manual
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _goToManualSelection,
                      icon: const Icon(Icons.edit),
                      label: const Text('Selecionar fazenda manualmente'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2;

        return Stack(
          children: [
            // Fundo escuro ao redor da área de scan
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Borda da área de scan
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryGreen, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Cantos decorativos
            _buildCorner(left, top, true, true),
            _buildCorner(left + scanAreaSize - 40, top, true, false),
            _buildCorner(left, top + scanAreaSize - 40, false, true),
            _buildCorner(
              left + scanAreaSize - 40,
              top + scanAreaSize - 40,
              false,
              false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(double left, double top, bool isTop, bool isLeft) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.primaryGreen, width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: AppColors.primaryGreen, width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: AppColors.primaryGreen, width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: AppColors.primaryGreen, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionError(String error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                'Permissão de Câmera Necessária',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Para escanear o QR Code da fazenda, é necessário permitir o acesso à câmera.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  _scannerController?.start();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
