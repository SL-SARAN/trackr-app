import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class TrendChart extends StatelessWidget {
  final Map<DateTime, double> dailyTotals;
  final int trendDays;
  final String currencySymbol;
  final ValueChanged<int> onPeriodChanged;

  const TrendChart({
    super.key,
    required this.dailyTotals,
    required this.trendDays,
    required this.currencySymbol,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Build a complete list of spots for the period
    final List<FlSpot> spots = [];
    double maxY = 0;
    for (int i = 0; i < trendDays; i++) {
      final day = DateTime(now.year, now.month, now.day - (trendDays - 1 - i));
      final amount = _findAmount(day);
      if (amount > maxY) maxY = amount;
      spots.add(FlSpot(i.toDouble(), amount));
    }
    if (maxY == 0) maxY = 100;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Trend', style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
              _PeriodToggle(
                selected: trendDays,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: spots.length < 2
                ? Center(child: Text('Not enough data', style: theme.textTheme.bodySmall))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value == meta.max || value == meta.min) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                _compactAmount(value),
                                style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: _bottomInterval,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= trendDays) {
                                return const SizedBox.shrink();
                              }
                              final day = DateTime(
                                now.year, now.month, now.day - (trendDays - 1 - index),
                              );
                              return Text(
                                DateFormat('d/M').format(day),
                                style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: trendDays <= 7,
                            getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                              radius: 3,
                              color: theme.colorScheme.primary,
                              strokeWidth: 1.5,
                              strokeColor: theme.colorScheme.surface,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '$currencySymbol${spot.y.toStringAsFixed(0)}',
                                TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  double get _bottomInterval {
    if (trendDays <= 7) return 1;
    if (trendDays <= 30) return 5;
    return 30;
  }

  double _findAmount(DateTime day) {
    for (final entry in dailyTotals.entries) {
      if (entry.key.year == day.year &&
          entry.key.month == day.month &&
          entry.key.day == day.day) {
        return entry.value;
      }
    }
    return 0;
  }

  String _compactAmount(double amount) {
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _PeriodToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const options = [
      (label: '7D', value: 7),
      (label: '30D', value: 30),
      (label: '1Y', value: 365),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isActive = selected == opt.value;
          return GestureDetector(
            onTap: () => onChanged(opt.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
