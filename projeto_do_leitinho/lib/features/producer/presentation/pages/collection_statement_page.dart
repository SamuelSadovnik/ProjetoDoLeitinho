import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'collection_details_page.dart';

class CollectionStatementPage extends StatefulWidget {
  const CollectionStatementPage({super.key});

  @override
  State<CollectionStatementPage> createState() =>
      _CollectionStatementPageState();
}

class _CollectionStatementPageState extends State<CollectionStatementPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _collections = [
    {
      'id': 1,
      'date': '05/10/2025',
      'quantity': 350.0,
      'temperature': 4.5,
      'acidity': 15.0,
      'quality': 'Aprovado',
      'approved': true,
      'indicators': {'antibiotic': 'Negativo', 'fat': '3.8%'},
    },
    {
      'id': 2,
      'date': '04/10/2025',
      'quantity': 280.5,
      'temperature': 4.8,
      'acidity': 16.5,
      'quality': 'Aprovado',
      'approved': true,
      'indicators': {'antibiotic': 'Negativo', 'fat': '3.6%'},
    },
    {
      'id': 3,
      'date': '03/10/2025',
      'quantity': 320.0,
      'temperature': 5.2,
      'acidity': 18.0,
      'quality': 'Reprovado',
      'approved': false,
      'indicators': {'antibiotic': 'Positivo', 'fat': '3.5%'},
    },
  ];

  double get _totalLiters =>
      _collections.fold(0, (sum, c) => sum + c['quantity']);
  double get _approvedLiters => _collections
      .where((c) => c['approved'])
      .fold(0, (sum, c) => sum + c['quantity']);
  double get _rejectedLiters => _collections
      .where((c) => !c['approved'])
      .fold(0, (sum, c) => sum + c['quantity']);

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
      body: Column(
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
                        'Aprovado',
                        '${_approvedLiters.toStringAsFixed(1)}L',
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTotalCard(
                        'Reprovado',
                        '${_rejectedLiters.toStringAsFixed(1)}L',
                        AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final collection = _collections[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CollectionDetailsPage(collection: collection),
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
                              color: collection['approved']
                                  ? AppColors.success
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      collection['date'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${collection['quantity']}L',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: AppColors.primaryGreen,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildInfoChip(
                                      '${collection['temperature']}°C',
                                      Icons.thermostat,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildInfoChip(
                                      'Acidez: ${collection['acidity']}',
                                      Icons.science,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (collection['approved']
                                                ? AppColors.success
                                                : AppColors.error)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    collection['quality'],
                                    style: TextStyle(
                                      color: collection['approved']
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
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
