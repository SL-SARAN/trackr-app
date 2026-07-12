import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/category_alert_strip.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/next_up_card.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/trend_chart.dart';

class HomeScreen extends StatefulWidget {
  final String currencySymbol;
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.currencySymbol,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(
                  'Trackr',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                centerTitle: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              if (state.status == HomeStatus.loading && state.totalSpent == 0)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ReportSummaryCard(
                        totalIncome: state.totalIncome,
                        totalSpent: state.totalSpent,
                        netSavings: state.netSavings,
                        currencySymbol: widget.currencySymbol,
                        hasMonthlyIncome: state.hasMonthlyIncome,
                        onSetIncomeTap: () {
                          widget.onNavigateToTab?.call(3);
                        },
                      ),
                      const SizedBox(height: 16),
                      BudgetProgressCard(
                        totalSpent: state.totalSpent,
                        budgetAmount: state.budgetAmount,
                        currencySymbol: widget.currencySymbol,
                      ),
                      const SizedBox(height: 16),
                      CategoryDonutChart(
                        categories: state.categories,
                        spending: state.categorySpending,
                        currencySymbol: widget.currencySymbol,
                      ),
                      const SizedBox(height: 16),
                      CategoryAlertStrip(
                        categories: state.categories,
                        spending: state.categorySpending,
                        currencySymbol: widget.currencySymbol,
                      ),
                      const SizedBox(height: 16),
                      NextUpCard(tasks: state.nextUpTasks),
                      const SizedBox(height: 16),
                      TrendChart(
                        dailyTotals: state.dailyTotals,
                        trendDays: state.trendDays,
                        currencySymbol: widget.currencySymbol,
                        onPeriodChanged: (days) =>
                            context.read<HomeCubit>().changeTrendPeriod(days),
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
