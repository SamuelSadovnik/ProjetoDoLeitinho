import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'collection_statement_page.dart';
import 'monthly_comparison_page.dart';

class ProducerDashboardPage extends StatefulWidget {
  final UserModel user;

  const ProducerDashboardPage({super.key, required this.user});

  @override
  State<ProducerDashboardPage> createState() => _ProducerDashboardPageState();
}

class _ProducerDashboardPageState extends State<ProducerDashboardPage> {
  bool _isLoading = true;
  String? _errorMessage;

  // Stats data
  double _totalLiters = 0;
  double _averageDaily = 0;
  double _averageAcidity = 0;
  double _averageTemperature = 0;
  List<Map<String, dynamic>> _last30Days = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();

      final response = await apiService.getProducerStats(
        producerId: widget.user.iduser,
        year: DateTime.now().year,
        month: DateTime.now().month,
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = response.data;
        if (data['success'] == true && data['content'] != null) {
          final statsData = data['content'];
          final currentMonth = statsData['currentMonth'] ?? {};

          setState(() {
            _totalLiters = (currentMonth['totalLiters'] ?? 0).toDouble();
            _averageDaily = (currentMonth['averageDaily'] ?? 0).toDouble();
            _averageAcidity = (currentMonth['averageAcidity'] ?? 0).toDouble();
            _averageTemperature = (currentMonth['averageTemperature'] ?? 0)
                .toDouble();
            _last30Days = List<Map<String, dynamic>>.from(
              statsData['last30Days'] ?? [],
            );
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
        _errorMessage = 'Erro ao carregar estatísticas: $e';
      });
    }
  }

  List<FlSpot> _generateChartData() {
    if (_last30Days.isEmpty) {
      return [const FlSpot(0, 0)];
    }

    return _last30Days.asMap().entries.map((entry) {
      final quantity = (entry.value['quantity'] ?? 0).toDouble();
      return FlSpot(entry.key.toDouble(), quantity);
    }).toList();
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
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlyComparisonPage(producer: widget.user),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
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
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Total Mês Atual',
                          value: '${_totalLiters.toStringAsFixed(1)}L',
                          icon: Icons.local_drink,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Média Diária',
                          value: '${_averageDaily.toStringAsFixed(1)}L',
                          icon: Icons.trending_up,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Acidez Média',
                          value: '${_averageAcidity.toStringAsFixed(2)}',
                          icon: Icons.science,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Temp. Média',
                          value: '${_averageTemperature.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coletas - Mês Atual',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _last30Days.isEmpty
                                ? const Center(
                                    child: Text('Nenhuma coleta no período'),
                                  )
                                : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _generateChartData(),
                                          isCurved: true,
                                          color: AppColors.primaryGreen,
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: AppColors.softGreen
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CollectionStatementPage(producer: widget.user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Ver Extrato'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exportando PDF...'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportar PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: color),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
