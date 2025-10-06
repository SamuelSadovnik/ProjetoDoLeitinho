import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_collection_page.dart';

class CollectionHistoryPage extends StatefulWidget {
  const CollectionHistoryPage({super.key});

  @override
  State<CollectionHistoryPage> createState() => _CollectionHistoryPageState();
}

class _CollectionHistoryPageState extends State<CollectionHistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedFarm;

  final List<String> _farms = [
    'Todas',
    'Fazenda Santa Maria',
    'Fazenda Boa Vista',
    'Fazenda São João',
  ];

  final List<Map<String, dynamic>> _collections = [
    {
      'id': 1,
      'date': '05/10/2025 14:30',
      'farm': 'Fazenda Santa Maria',
      'producer': 'João Silva',
      'quantity': 350.0,
      'synced': true,
    },
    {
      'id': 2,
      'date': '05/10/2025 10:15',
      'farm': 'Fazenda Boa Vista',
      'producer': 'Maria Santos',
      'quantity': 280.5,
      'synced': true,
    },
    {
      'id': 3,
      'date': '04/10/2025 16:45',
      'farm': 'Fazenda São João',
      'producer': 'Pedro Oliveira',
      'quantity': 420.0,
      'synced': false,
    },
  ];

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
        title: const Text('Histórico de Coletas'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
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
                      },
                      icon: const Icon(Icons.clear),
                      color: AppColors.lightGray,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Fazenda',
                    prefixIcon: Icon(Icons.terrain),
                    isDense: true,
                  ),
                  value: _selectedFarm ?? 'Todas',
                  items: _farms.map((farm) {
                    return DropdownMenuItem(value: farm, child: Text(farm));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFarm = value;
                    });
                  },
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: collection['synced']
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2),
                      child: Icon(
                        collection['synced']
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: collection['synced']
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    title: Text(
                      collection['farm'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${collection['date']} • ${collection['quantity']}L',
                        ),
                        Text(
                          collection['synced']
                              ? 'Sincronizado'
                              : 'Aguardando sincronização',
                          style: TextStyle(
                            color: collection['synced']
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.primaryGreen,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditCollectionPage(collection: collection),
                          ),
                        );
                      },
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
