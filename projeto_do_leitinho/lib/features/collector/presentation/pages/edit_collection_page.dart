import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class EditCollectionPage extends StatefulWidget {
  final CollectionModel collection;
  final UserModel collector;

  const EditCollectionPage({
    super.key,
    required this.collection,
    required this.collector,
  });

  @override
  State<EditCollectionPage> createState() => _EditCollectionPageState();
}

class _EditCollectionPageState extends State<EditCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _acidityController;
  late final TextEditingController _observationsController;

  FarmModel? _selectedFarm;
  UserModel? _selectedProducer;
  AnimalModel? _selectedAnimal;
  late bool _producerPresent;
  bool _isLoading = true;
  bool _isSaving = false;

  List<FarmModel> _farms = [];
  List<UserModel> _producers = [];
  List<AnimalModel> _animals = [];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.collection.quantity.toString(),
    );
    _temperatureController = TextEditingController(
      text: widget.collection.temperature.toString(),
    );
    _acidityController = TextEditingController(
      text: widget.collection.acidity.toString(),
    );
    _observationsController = TextEditingController(
      text: widget.collection.observations,
    );
    _producerPresent = widget.collection.producerPresent;
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

          // Selecionar a fazenda da coleta
          _selectedFarm = _farms.firstWhere(
            (f) => f.idfarm == widget.collection.farm.idfarm,
            orElse: () => _farms.first,
          );
        }
      }

      // Buscar produtores
      final usersResponse = await apiService.getAllUsers();
      if (usersResponse.statusCode == 200 || usersResponse.statusCode == 202) {
        final data = usersResponse.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> usersJson = data['content'];
          _producers = usersJson
              .map((u) => UserModel.fromJson(u))
              .where((u) => u.isProducer && u.active)
              .toList();

          // Selecionar o produtor da coleta
          _selectedProducer = _producers.firstWhere(
            (p) => p.iduser == widget.collection.producer.iduser,
            orElse: () => _producers.first,
          );
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

          // Selecionar o animal da coleta
          _selectedAnimal = _animals.firstWhere(
            (a) => a.idanimal == widget.collection.animal.idanimal,
            orElse: () => _animals.first,
          );
        }
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
      setState(() {
        _isSaving = true;
      });

      try {
        final apiService = context.read<ApiService>();

        final response = await apiService.updateCollection(
          idCollection: widget.collection.idcollection,
          farmId: _selectedFarm!.idfarm,
          producerId: _selectedProducer!.iduser,
          collectorId: widget.collector.iduser,
          animalId: _selectedAnimal!.idanimal,
          quantity: double.parse(_quantityController.text),
          temperature: double.parse(_temperatureController.text),
          acidity: double.parse(_acidityController.text),
          producerPresent: _producerPresent,
          observations: _observationsController.text,
          collectionDate: widget.collection.collectionDate,
        );

        if (response.statusCode == 200 || response.statusCode == 202) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alterações salvas com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw Exception(response.data['message'] ?? 'Erro ao salvar');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar alterações: $e'),
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
        title: const Text('Editar Coleta'),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ID: ${widget.collection.idcollection} • ${widget.collection.formattedDate}',
                            style: const TextStyle(color: AppColors.darkBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.lightGray,
                                  side: const BorderSide(
                                    color: AppColors.lightGray,
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _handleSave,
                                child: const Text('Salvar Alterações'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
    );
  }
}
