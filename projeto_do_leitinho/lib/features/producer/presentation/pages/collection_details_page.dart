import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CollectionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> collection;

  const CollectionDetailsPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Coleta'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.snowWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        collection['approved']
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: collection['approved']
                            ? AppColors.success
                            : AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection['quality'],
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: collection['approved']
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                            ),
                            Text(
                              'ID: ${collection['id']} • ${collection['date']}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Informações da Coleta',
            children: [
              _buildInfoRow(
                context,
                'Quantidade',
                '${collection['quantity']}L',
                Icons.local_drink,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Temperatura',
                '${collection['temperature']}°C',
                Icons.thermostat,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Acidez',
                '${collection['acidity']}',
                Icons.science,
              ),
              const Divider(height: 24),
              _buildInfoRow(context, 'Coletor', 'João Silva', Icons.person),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Indicadores de Qualidade',
            children: [
              _buildIndicatorRow(
                context,
                'Antibiótico',
                collection['indicators']['antibiotic'],
                collection['indicators']['antibiotic'] == 'Negativo',
              ),
              const Divider(height: 24),
              _buildIndicatorRow(
                context,
                'Gordura',
                collection['indicators']['fat'],
                true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Observações',
            children: [
              Text(
                collection['approved']
                    ? 'Leite dentro dos padrões de qualidade.'
                    : 'Leite reprovado devido à presença de antibiótico.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(
    BuildContext context,
    String label,
    String value,
    bool isGood,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isGood ? AppColors.success : AppColors.error).withOpacity(
              0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isGood ? Icons.check : Icons.close,
            color: isGood ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isGood ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
