import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryAlertStrip extends StatelessWidget {
  final List<CategoryEntity> categories;
  final Map<int, double> spending;
  final String currencySymbol;

  const CategoryAlertStrip({
    super.key,
    required this.categories,
    required this.spending,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    // Only show categories that have a budget limit set
    final alerts = <_AlertData>[];
    for (final cat in categories) {
      if (cat.budgetLimit == null || cat.budgetLimit! <= 0) continue;
      final spent = spending[cat.id] ?? 0;
      final ratio = spent / cat.budgetLimit!;
      if (ratio >= 0.7) {
        alerts.add(_AlertData(category: cat, spent: spent, ratio: ratio));
      }
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    // Sort by ratio descending (most critical first)
    alerts.sort((a, b) => b.ratio.compareTo(a.ratio));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Category Alerts',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: alerts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final alert = alerts[i];
              final color = alert.ratio > 1.0
                  ? AppColors.budgetOver
                  : AppColors.budgetWarn;
              final pct = (alert.ratio * 100).toStringAsFixed(0);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: alert.category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${alert.category.name}: $pct%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }
}

class _AlertData {
  final CategoryEntity category;
  final double spent;
  final double ratio;

  _AlertData({
    required this.category,
    required this.spent,
    required this.ratio,
  });
}
