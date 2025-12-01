import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'collection_history_page.dart';
import 'scan_farm_qr_page.dart';

class CollectorDashboardPage extends StatefulWidget {
  final UserModel user;

  const CollectorDashboardPage({super.key, required this.user});

  @override
  State<CollectorDashboardPage> createState() => _CollectorDashboardPageState();
}

class _CollectorDashboardPageState extends State<CollectorDashboardPage> {
  bool _isLoading = true;
  int _collectionsToday = 0;
  CollectionModel? _lastCollection;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();

      // Buscar histórico de coletas do coletor
      final response = await apiService.getCollectorHistory(
        collectorId: widget.user.iduser,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now(),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data;
        if (data['success'] == true && data['content'] != null) {
          final List<dynamic> collectionsJson = data['content'];

          // Contar coletas de hoje
          final today = DateTime.now();
          int todayCount = 0;
          CollectionModel? lastCol;

          for (var colJson in collectionsJson) {
            final collection = CollectionModel.fromJson(colJson);
            if (collection.collectionDate.day == today.day &&
                collection.collectionDate.month == today.month &&
                collection.collectionDate.year == today.year) {
              todayCount++;
            }
            if (lastCol == null ||
                collection.collectionDate.isAfter(lastCol.collectionDate)) {
              lastCol = collection;
            }
          }

          setState(() {
            _collectionsToday = todayCount;
            _lastCollection = lastCol;
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
        _errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${widget.user.name.split(' ').first}'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null)
                        Card(
                          color: AppColors.error.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ),
                      _buildStatCard(
                        context,
                        title: 'Coletas Hoje',
                        value: '$_collectionsToday',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        context,
                        title: 'Última Coleta',
                        value: _lastCollection != null
                            ? '${_lastCollection!.quantity.toStringAsFixed(1)}L'
                            : 'Nenhuma',
                        subtitle: _lastCollection != null
                            ? '${_lastCollection!.farm.name} - ${_lastCollection!.formattedDate}'
                            : null,
                        icon: Icons.access_time,
                        color: AppColors.info,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ScanFarmQrPage(collector: widget.user),
                            ),
                          );
                          _loadDashboardData();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nova Coleta'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CollectionHistoryPage(collector: widget.user),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Histórico'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.all(20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.displayMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
