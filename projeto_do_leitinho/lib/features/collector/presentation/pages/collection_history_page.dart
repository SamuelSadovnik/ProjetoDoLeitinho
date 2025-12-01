import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'edit_collection_page.dart';

class CollectionHistoryPage extends StatefulWidget {
  final UserModel collector;

  const CollectionHistoryPage({super.key, required this.collector});

  @override
  State<CollectionHistoryPage> createState() => _CollectionHistoryPageState();
}

class _CollectionHistoryPageState extends State<CollectionHistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  FarmModel? _selectedFarm;
  bool _isLoading = true;

  List<FarmModel> _farms = [];
  List<CollectionModel> _collections = [];

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

      // Buscar histórico de coletas
      await _loadCollections();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCollections() async {
    try {
      final apiService = context.read<ApiService>();

      final response = await apiService.getCollectorHistory(
        collectorId: widget.collector.iduser,
        farmId: _selectedFarm?.idfarm,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> collectionsJson = data['content'];
          setState(() {
            _collections = collectionsJson
                .map((c) => CollectionModel.fromJson(c))
                .toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar coletas: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryGreen),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCollections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Coletas'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.softGreen.withOpacity(0.2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectDateRange(context),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _startDate != null && _endDate != null
                                    ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                                    : 'Filtrar período',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                              _loadCollections();
                            },
                            icon: const Icon(Icons.clear),
                            color: AppColors.lightGray,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<FarmModel?>(
                        decoration: const InputDecoration(
                          labelText: 'Fazenda',
                          prefixIcon: Icon(Icons.terrain),
                          isDense: true,
                        ),
                        value: _selectedFarm,
                        items: [
                          const DropdownMenuItem<FarmModel?>(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ..._farms.map((farm) {
                            return DropdownMenuItem(
                              value: farm,
                              child: Text(farm.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFarm = value;
                          });
                          _loadCollections();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _collections.isEmpty
                      ? const Center(child: Text('Nenhuma coleta encontrada'))
                      : RefreshIndicator(
                          onRefresh: _loadCollections,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _collections.length,
                            itemBuilder: (context, index) {
                              final collection = _collections[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: collection.edited
                                        ? AppColors.warning.withOpacity(0.2)
                                        : AppColors.success.withOpacity(0.2),
                                    child: Icon(
                                      collection.edited
                                          ? Icons.edit_note
                                          : Icons.cloud_done,
                                      color: collection.edited
                                          ? AppColors.warning
                                          : AppColors.success,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          collection.farm.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (collection.edited)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Editada${collection.editCount > 1 ? ' ${collection.editCount}x' : ''}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.warning,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        '${collection.formattedDate} • ${collection.quantity.toStringAsFixed(1)}L',
                                      ),
                                      Text(
                                        'Produtor: ${collection.producer.name}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: AppColors.primaryGreen,
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditCollectionPage(
                                            collection: collection,
                                            collector: widget.collector,
                                          ),
                                        ),
                                      );
                                      _loadCollections();
                                    },
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
