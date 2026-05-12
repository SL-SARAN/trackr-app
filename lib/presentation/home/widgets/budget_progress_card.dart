import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class BudgetProgressCard extends StatelessWidget {
  final double totalSpent;
  final double? budgetAmount;
  final String currencySymbol;

  const BudgetProgressCard({
    super.key,
    required this.totalSpent,
    required this.budgetAmount,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBudget = budgetAmount != null && budgetAmount! > 0;
    final progress = hasBudget ? (totalSpent / budgetAmount!).clamp(0.0, 1.5) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    Color progressColor;
    String statusText;
    if (progress > 1.0) {
      progressColor = AppColors.budgetOver;
      statusText = 'Over budget';
    } else if (progress > 0.7) {
      progressColor = AppColors.budgetWarn;
      statusText = 'Nearing limit';
    } else {
      progressColor = AppColors.budgetSafe;
      statusText = 'On track';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Budget', style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
              if (hasBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasBudget) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currencySymbol ${totalSpent.toStringAsFixed(0)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '/ $currencySymbol ${budgetAmount!.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$percentage%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: progressColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ] else
            Text(
              'No budget set yet.\nGo to Settings to set your monthly budget.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}
