import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/category_defaults.dart';
import '../cubit/onboarding_cubit.dart';

class CurrencySetupScreen extends StatefulWidget {
  const CurrencySetupScreen({super.key});

  @override
  State<CurrencySetupScreen> createState() => _CurrencySetupScreenState();
}

class _CurrencySetupScreenState extends State<CurrencySetupScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final filtered = kCurrencies
        .where((c) =>
            c.name.toLowerCase().contains(_query.toLowerCase()) ||
            c.code.toLowerCase().contains(_query.toLowerCase()) ||
            c.symbol.contains(_query))
        .toList();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.isDone) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Header
                  Text(
                    'Trackr',
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                  const SizedBox(height: 8),

                  Text(
                    'Select your currency to get started.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 32),

                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search currency...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 16),

                  // Currency list
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final currency = filtered[i];
                        final isSelected = state.selected?.code == currency.code;

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.12)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              currency.symbol,
                              style: textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            currency.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          subtitle: Text(
                            currency.code,
                            style: textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: colorScheme.primary)
                              : null,
                          onTap: () => context
                              .read<OnboardingCubit>()
                              .selectCurrency(currency),
                        );
                      },
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                  ),

                  const SizedBox(height: 16),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.selected == null || state.isLoading
                          ? null
                          : () => context.read<OnboardingCubit>().confirm(),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
