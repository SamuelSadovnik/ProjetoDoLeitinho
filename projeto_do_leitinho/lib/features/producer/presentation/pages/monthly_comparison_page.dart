import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class MonthlyComparisonPage extends StatefulWidget {
  final UserModel producer;

  const MonthlyComparisonPage({super.key, required this.producer});

  @override
  State<MonthlyComparisonPage> createState() => _MonthlyComparisonPageState();
}

class _MonthlyComparisonPageState extends State<MonthlyComparisonPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = true;

  double _currentMonthTotal = 0;
  double _previousMonthTotal = 0;

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

      // Carregar mês atual
      final currentResponse = await apiService.getProducerStats(
        producerId: widget.producer.iduser,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (currentResponse.statusCode == 200 ||
          currentResponse.statusCode == 202) {
        final data = currentResponse.data;
        if (data['success'] == true && data['content'] != null) {
          final currentMonth = data['content']['currentMonth'] ?? {};
          _currentMonthTotal = (currentMonth['totalLiters'] ?? 0).toDouble();
        }
      }

      // Carregar mês anterior
      int prevMonth = _selectedMonth - 1;
      int prevYear = _selectedYear;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear = _selectedYear - 1;
      }

      final previousResponse = await apiService.getProducerStats(
        producerId: widget.producer.iduser,
        year: prevYear,
        month: prevMonth,
      );

      if (previousResponse.statusCode == 200 ||
          previousResponse.statusCode == 202) {
        final data = previousResponse.data;
        if (data['success'] == true && data['content'] != null) {
          final previousMonth = data['content']['currentMonth'] ?? {};
          _previousMonthTotal = (previousMonth['totalLiters'] ?? 0).toDouble();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double get _totalVariation {
    if (_previousMonthTotal == 0) return 0;
    return ((_currentMonthTotal - _previousMonthTotal) / _previousMonthTotal) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparativo Mensal'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            decoration: const InputDecoration(
                              labelText: 'Mês',
                              isDense: true,
                            ),
                            items: List.generate(12, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text(_getMonthName(index + 1)),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value!;
                              });
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Ano',
                              isDense: true,
                            ),
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value!;
                              });
                              _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMonthCard(
                        context,
                        title: 'Mês Atual',
                        value: '${_currentMonthTotal.toStringAsFixed(0)}L',
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMonthCard(
                        context,
                        title: 'Mês Anterior',
                        value: '${_previousMonthTotal.toStringAsFixed(0)}L',
                        color: AppColors.lightGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  color: _totalVariation >= 0
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          _totalVariation >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 48,
                          color: _totalVariation >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Variação',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_totalVariation >= 0 ? '+' : ''}${_totalVariation.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: _totalVariation >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gráfico Comparativo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 280,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, right: 16),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(),
                                minY: 0,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                          final label = rodIndex == 0
                                              ? 'Mês Anterior'
                                              : 'Mês Atual';
                                          return BarTooltipItem(
                                            '$label\n${rod.toY.toStringAsFixed(0)}L',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 45,
                                      interval: _getMaxY() / 4,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: Text(
                                            value.toStringAsFixed(0),
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: _getMaxY() / 4,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barsSpace: 12,
                                    barRods: [
                                      BarChartRodData(
                                        toY: _previousMonthTotal,
                                        color: AppColors.lightGray,
                                        width: 50,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                      BarChartRodData(
                                        toY: _currentMonthTotal,
                                        color: AppColors.primaryGreen,
                                        width: 50,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                              'Mês Anterior',
                              AppColors.lightGray,
                            ),
                            const SizedBox(width: 24),
                            _buildLegendItem(
                              'Mês Atual',
                              AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  /// Calcula o valor máximo do eixo Y baseado nos dados
  double _getMaxY() {
    final maxValue = _currentMonthTotal > _previousMonthTotal
        ? _currentMonthTotal
        : _previousMonthTotal;

    if (maxValue == 0) return 100;

    // Adiciona 20% de margem e arredonda para um número bonito
    final withMargin = maxValue * 1.2;

    if (withMargin <= 100) return 100;
    if (withMargin <= 500) return 500;
    if (withMargin <= 1000) return 1000;
    if (withMargin <= 2000) return 2000;
    if (withMargin <= 5000) return 5000;
    if (withMargin <= 10000) return 10000;

    return (withMargin / 1000).ceil() * 1000;
  }
}
