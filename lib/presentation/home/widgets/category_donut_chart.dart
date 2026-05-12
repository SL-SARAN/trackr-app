import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryDonutChart extends StatefulWidget {
  final List<CategoryEntity> categories;
  final Map<int, double> spending;
  final String currencySymbol;

  const CategoryDonutChart({
    super.key,
    required this.categories,
    required this.spending,
    required this.currencySymbol,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSpent = widget.spending.values.fold(0.0, (a, b) => a + b);

    // Only show categories that have spending
    final activeCategories = widget.categories.where(
      (c) => (widget.spending[c.id] ?? 0) > 0,
    ).toList();

    if (activeCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('Spending by Category', style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )),
            const SizedBox(height: 24),
            Icon(Icons.donut_large_outlined,
                size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 8),
            Text('No expenses yet',
                style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category', style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          )),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = null;
                              return;
                            }
                            _touchedIndex = response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: List.generate(activeCategories.length, (i) {
                        final cat = activeCategories[i];
                        final amount = widget.spending[cat.id] ?? 0;
                        final pct = totalSpent > 0 ? (amount / totalSpent * 100) : 0;
                        final isTouched = _touchedIndex == i;
                        return PieChartSectionData(
                          color: cat.color,
                          value: amount,
                          title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
                          radius: isTouched ? 28 : 22,
                          titleStyle: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: activeCategories.take(5).map((cat) {
                      final amount = widget.spending[cat.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: cat.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: theme.textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${widget.currencySymbol}${amount.toStringAsFixed(0)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }
}
