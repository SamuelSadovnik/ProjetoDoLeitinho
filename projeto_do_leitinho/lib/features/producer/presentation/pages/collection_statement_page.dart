import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'collection_details_page.dart';

class CollectionStatementPage extends StatefulWidget {
  final UserModel producer;

  const CollectionStatementPage({super.key, required this.producer});

  @override
  State<CollectionStatementPage> createState() =>
      _CollectionStatementPageState();
}

class _CollectionStatementPageState extends State<CollectionStatementPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;
  List<CollectionModel> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();

      final response = await apiService.getProducerCollections(
        widget.producer.iduser,
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> collectionsJson = data['content'];
          setState(() {
            _collections = collectionsJson
                .map((c) => CollectionModel.fromJson(c))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  List<CollectionModel> get _filteredCollections {
    if (_startDate == null || _endDate == null) {
      return _collections;
    }

    return _collections.where((c) {
      return c.collectionDate.isAfter(_startDate!) &&
          c.collectionDate.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  double get _totalLiters =>
      _filteredCollections.fold(0, (sum, c) => sum + c.quantity);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato de Coletas'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCollections,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportando PDF...'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
        ],
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
                                    : 'Selecionar período',
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
                            },
                            icon: const Icon(Icons.clear),
                            color: AppColors.lightGray,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTotalCard(
                              'Total',
                              '${_totalLiters.toStringAsFixed(1)}L',
                              AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTotalCard(
                              'Coletas',
                              '${_filteredCollections.length}',
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredCollections.isEmpty
                      ? const Center(child: Text('Nenhuma coleta encontrada'))
                      : RefreshIndicator(
                          onRefresh: _loadCollections,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCollections.length,
                            itemBuilder: (context, index) {
                              final collection = _filteredCollections[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CollectionDetailsPage(
                                          collection: collection,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.success,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    collection.formattedDate,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '${collection.quantity.toStringAsFixed(1)}L',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .primaryGreen,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  _buildInfoChip(
                                                    '${collection.temperature.toStringAsFixed(1)}°C',
                                                    Icons.thermostat,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildInfoChip(
                                                    'Acidez: ${collection.acidity.toStringAsFixed(2)}',
                                                    Icons.science,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                collection.farm.name,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.lightGray,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.lightGray,
                                        ),
                                      ],
                                    ),
                                  ),
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

  Widget _buildTotalCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.lightGray),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.lightGray),
        ),
      ],
    );
  }
}
