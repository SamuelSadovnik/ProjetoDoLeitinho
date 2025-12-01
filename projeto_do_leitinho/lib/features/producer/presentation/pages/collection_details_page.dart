import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/models.dart';

class CollectionDetailsPage extends StatelessWidget {
  final CollectionModel collection;

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
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coleta #${collection.idcollection}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppColors.success),
                            ),
                            Text(
                              collection.formattedDate,
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
                '${collection.quantity.toStringAsFixed(1)}L',
                Icons.local_drink,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Temperatura',
                '${collection.temperature.toStringAsFixed(1)}°C',
                Icons.thermostat,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Acidez',
                collection.acidity.toStringAsFixed(2),
                Icons.science,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Coletor',
                collection.collector.name,
                Icons.person,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Fazenda',
                collection.farm.name,
                Icons.terrain,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                'Produtor Presente',
                collection.producerPresent ? 'Sim' : 'Não',
                collection.producerPresent ? Icons.check : Icons.close,
              ),
            ],
          ),
          if (collection.observations.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Observações',
              children: [
                Text(
                  collection.observations,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
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
}
