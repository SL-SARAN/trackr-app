import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/task_entity.dart';
import 'package:intl/intl.dart';

class NextUpCard extends StatelessWidget {
  final List<TaskEntity> tasks;

  const NextUpCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Text('Next Up', style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          )),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No upcoming tasks.',
                style: theme.textTheme.bodySmall,
              ),
            )
          else
            ...tasks.map((task) => _TaskItem(task: task)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1);
  }
}

class _TaskItem extends StatelessWidget {
  final TaskEntity task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('MMM d, h:mm a').format(task.scheduledAt);

    Color importanceColor;
    switch (task.importance) {
      case ImportanceLevel.high:
        importanceColor = AppColors.importanceHigh;
      case ImportanceLevel.medium:
        importanceColor = AppColors.importanceMedium;
      case ImportanceLevel.low:
        importanceColor = AppColors.importanceLow;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: importanceColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: importanceColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.importance.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: importanceColor,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
