import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/expense_entity.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';

class AnalyticsScreen extends StatefulWidget {
  final String currencySymbol;
  const AnalyticsScreen({super.key, required this.currencySymbol});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AnalyticsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return Column(
            children: [
              // ─── Filters ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  context.read<AnalyticsCubit>().setSearch(null);
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (v) =>
                          context.read<AnalyticsCubit>().setSearch(v),
                    ),
                    const SizedBox(height: 10),

                    // Category chips + date filter
                    SizedBox(
                      height: 34,
                      child: Row(
                        children: [
                          // Date range button
                          _FilterChip(
                            label: state.filterFrom != null
                                ? '${DateFormat('d/M').format(state.filterFrom!)} - ${DateFormat('d/M').format(state.filterTo ?? DateTime.now())}'
                                : 'Date Range',
                            isActive: state.filterFrom != null,
                            onTap: () => _pickDateRange(context),
                            onClear: state.filterFrom != null
                                ? () => context
                                    .read<AnalyticsCubit>()
                                    .setDateRange(null, null)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          // Category chips
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  isActive: state.filterCategoryId == null,
                                  onTap: () => context
                                      .read<AnalyticsCubit>()
                                      .setCategory(null),
                                ),
                                const SizedBox(width: 6),
                                ...state.categories.map((cat) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _FilterChip(
                                      label: cat.name,
                                      isActive:
                                          state.filterCategoryId == cat.id,
                                      color: cat.color,
                                      onTap: () => context
                                          .read<AnalyticsCubit>()
                                          .setCategory(cat.id),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Expense List ────────────────────────────
              Expanded(
                child: state.status == AnalyticsStatus.loading &&
                        state.expenses.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 56,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.2)),
                                const SizedBox(height: 12),
                                Text('No expenses found',
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            itemCount: state.expenses.length +
                                (state.hasMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == state.expenses.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              final expense = state.expenses[i];
                              final category = state.categories
                                  .where((c) => c.id == expense.categoryId)
                                  .firstOrNull;

                              return _ExpenseTile(
                                expense: expense,
                                category: category,
                                currencySymbol: widget.currencySymbol,
                                onDismissed: () => context
                                    .read<AnalyticsCubit>()
                                    .deleteExpense(expense.id),
                              ).animate().fadeIn(
                                    duration: 200.ms,
                                    delay: Duration(
                                        milliseconds: (i % 10) * 30),
                                  );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );
    if (picked != null && context.mounted) {
      context.read<AnalyticsCubit>().setDateRange(picked.start, picked.end);
    }
  }
}

// ─── Expense Tile ────────────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final CategoryEntity? category;
  final String currencySymbol;
  final VoidCallback onDismissed;

  const _ExpenseTile({
    required this.expense,
    required this.category,
    required this.currencySymbol,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('MMM d, yyyy');

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.dangerLight.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.dangerLight),
      ),
      onDismissed: (_) => onDismissed(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Category dot
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (category?.color ?? Colors.grey).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: category?.color ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Unknown',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        dateFmt.format(expense.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          expense.timeOfDayTag.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (expense.description != null &&
                      expense.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        expense.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Amount
            Text(
              '$currencySymbol ${expense.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.isActive,
    this.color,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? (color ?? theme.colorScheme.primary).withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: (color ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null && isActive) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? (color ?? theme.colorScheme.primary)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 14,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
