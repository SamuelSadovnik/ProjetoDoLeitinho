import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class NewCollectionPage extends StatefulWidget {
  const NewCollectionPage({super.key});

  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _acidityController = TextEditingController();
  final _observationsController = TextEditingController();

  String? _selectedFarm;
  String? _selectedProducer;
  bool _producerPresent = false;

  final List<String> _farms = [
    'Fazenda Santa Maria',
    'Fazenda Boa Vista',
    'Fazenda São João',
  ];

  final List<String> _producers = [
    'João Silva',
    'Maria Santos',
    'Pedro Oliveira',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _temperatureController.dispose();
    _acidityController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coleta salva com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Fazenda',
                prefixIcon: Icon(Icons.terrain),
              ),
              value: _selectedFarm,
              items: _farms.map((farm) {
                return DropdownMenuItem(value: farm, child: Text(farm));
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
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Produtor',
                prefixIcon: Icon(Icons.person),
              ),
              value: _selectedProducer,
              items: _producers.map((producer) {
                return DropdownMenuItem(value: producer, child: Text(producer));
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
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantidade (litros)',
                prefixIcon: Icon(Icons.local_drink),
                suffixText: 'L',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
            ElevatedButton(
              onPressed: _handleSave,
              child: const Text('Salvar Coleta'),
            ),
          ],
        ),
      ),
    );
  }
}
