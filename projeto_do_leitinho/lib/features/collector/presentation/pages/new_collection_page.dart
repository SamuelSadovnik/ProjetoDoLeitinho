import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class NewCollectionPage extends StatefulWidget {
  final UserModel collector;
  final FarmModel? preSelectedFarm;

  const NewCollectionPage({
    super.key,
    required this.collector,
    this.preSelectedFarm,
  });

  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _acidityController = TextEditingController();
  final _observationsController = TextEditingController();

  FarmModel? _selectedFarm;
  UserModel? _selectedProducer;
  AnimalModel? _selectedAnimal;
  bool _producerPresent = false;
  bool _isLoading = true;
  bool _isSaving = false;

  List<FarmModel> _farms = [];
  List<UserModel> _producers = [];
  List<AnimalModel> _animals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();

      // Buscar fazendas
      final farmsResponse = await apiService.getAllFarms();
      if (farmsResponse.statusCode == 200 || farmsResponse.statusCode == 202) {
        final data = farmsResponse.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> farmsJson = data['content'];
          _farms = farmsJson.map((f) => FarmModel.fromJson(f)).toList();
        }
      }

      // Buscar produtores (usuários do tipo produtor)
      final usersResponse = await apiService.getAllUsers();
      if (usersResponse.statusCode == 200 || usersResponse.statusCode == 202) {
        final data = usersResponse.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> usersJson = data['content'];
          _producers = usersJson
              .map((u) => UserModel.fromJson(u))
              .where((u) => u.isProducer && u.active)
              .toList();
        }
      }

      // Buscar animais
      final animalsResponse = await apiService.getAllAnimals();
      if (animalsResponse.statusCode == 200 ||
          animalsResponse.statusCode == 202) {
        final data = animalsResponse.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> animalsJson = data['content'];
          _animals = animalsJson.map((a) => AnimalModel.fromJson(a)).toList();
          // Selecionar o primeiro animal como padrão
          if (_animals.isNotEmpty) {
            _selectedAnimal = _animals.first;
          }
        }
      }

      // Se há uma fazenda pré-selecionada via QR Code, usar ela
      if (widget.preSelectedFarm != null) {
        _selectedFarm = _farms.firstWhere(
          (f) => f.idfarm == widget.preSelectedFarm!.idfarm,
          orElse: () => widget.preSelectedFarm!,
        );
        // Auto-selecionar o produtor da fazenda
        final matchingProducer = _producers
            .where((p) => p.iduser == _selectedFarm!.producer.iduser)
            .firstOrNull;
        _selectedProducer = matchingProducer;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _temperatureController.dispose();
    _acidityController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFarm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma fazenda'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedProducer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um produtor'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedAnimal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um animal'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final apiService = context.read<ApiService>();

        final response = await apiService.createCollection(
          farmId: _selectedFarm!.idfarm,
          producerId: _selectedProducer!.iduser,
          collectorId: widget.collector.iduser,
          animalId: _selectedAnimal!.idanimal,
          quantity: double.parse(_quantityController.text),
          temperature: double.parse(_temperatureController.text),
          acidity: double.parse(_acidityController.text),
          producerPresent: _producerPresent,
          observations: _observationsController.text,
          collectionDate: DateTime.now(),
        );

        if (response.statusCode == 200 || response.statusCode == 202) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coleta salva com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw Exception(response.data['message'] ?? 'Erro ao salvar coleta');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar coleta: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Coleta'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<FarmModel>(
                    decoration: const InputDecoration(
                      labelText: 'Fazenda',
                      prefixIcon: Icon(Icons.terrain),
                    ),
                    value: _selectedFarm,
                    items: _farms.map((farm) {
                      return DropdownMenuItem(
                        value: farm,
                        child: Text(farm.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFarm = value;
                        // Auto-selecionar o produtor da fazenda
                        if (value != null) {
                          // Buscar o produtor correspondente na lista de produtores
                          final matchingProducer = _producers
                              .where((p) => p.iduser == value.producer.iduser)
                              .firstOrNull;
                          _selectedProducer = matchingProducer;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione uma fazenda';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserModel>(
                    decoration: const InputDecoration(
                      labelText: 'Produtor',
                      prefixIcon: Icon(Icons.person),
                    ),
                    value: _selectedProducer,
                    items: _producers.map((producer) {
                      return DropdownMenuItem(
                        value: producer,
                        child: Text(producer.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProducer = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione um produtor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AnimalModel>(
                    decoration: const InputDecoration(
                      labelText: 'Animal',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    value: _selectedAnimal,
                    items: _animals.map((animal) {
                      return DropdownMenuItem(
                        value: animal,
                        child: Text(animal.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAnimal = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione um animal';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade (litros)',
                      prefixIcon: Icon(Icons.local_drink),
                      suffixText: 'L',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperatura',
                      prefixIcon: Icon(Icons.thermostat),
                      suffixText: '°C',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _acidityController,
                    decoration: const InputDecoration(
                      labelText: 'Acidez',
                      prefixIcon: Icon(Icons.science),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Produtor presente'),
                    value: _producerPresent,
                    onChanged: (value) {
                      setState(() {
                        _producerPresent = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryGreen,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observationsController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      prefixIcon: Icon(Icons.note),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleSave,
                          child: const Text('Salvar Coleta'),
                        ),
                ],
              ),
            ),
    );
  }
}
