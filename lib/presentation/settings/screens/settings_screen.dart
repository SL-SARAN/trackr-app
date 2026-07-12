import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../services/csv_export_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../shared/cubit/theme_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().load();
    _checkNotificationPermission();
    _checkBiometrics();
  }

  Future<void> _checkNotificationPermission() async {
    final enabled = await sl<NotificationService>().hasPermission();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _checkBiometrics() async {
    final auth = sl<AuthService>();
    final supported = await auth.isDeviceSupported();
    final canCheck = await auth.canCheckBiometrics();
    if (mounted) setState(() => _biometricsAvailable = supported || canCheck);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        // Sync theme changes to the global ThemeCubit
        final themeCubit = context.read<ThemeCubit>();
        themeCubit.setMode(
          state.isDarkMode ? AppThemeMode.dark : AppThemeMode.light,
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            centerTitle: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Budget Section
                    _SectionHeader(label: 'Budget'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Monthly Budget', style: theme.textTheme.titleSmall),
                              Text(
                                state.budgetAmount != null && state.budgetAmount! > 0
                                    ? '${state.currencySymbol} ${state.budgetAmount!.toStringAsFixed(0)}'
                                    : 'Not set',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _showBudgetDialog(context, state),
                              child: Text(
                                state.budgetAmount != null && state.budgetAmount! > 0
                                    ? 'Update Budget'
                                    : 'Set Budget',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Appearance Section
                    _SectionHeader(label: 'Appearance'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Dark Mode', style: theme.textTheme.titleSmall),
                        subtitle: Text(
                          state.isDarkMode ? 'On' : 'Off',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: state.isDarkMode,
                        onChanged: (v) => context.read<SettingsCubit>().setDarkMode(v),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notifications Section
                    _SectionHeader(label: 'Notifications'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _notificationsEnabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          color: _notificationsEnabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        title: Text('Task Reminders',
                            style: theme.textTheme.titleSmall),
                        subtitle: Text(
                          _notificationsEnabled ? 'Enabled' : 'Disabled — tap to open settings',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _notificationsEnabled
                                ? null
                                : theme.colorScheme.error,
                          ),
                        ),
                        trailing: Icon(
                          _notificationsEnabled
                              ? Icons.check_circle
                              : Icons.chevron_right,
                          color: _notificationsEnabled
                              ? theme.colorScheme.primary
                              : null,
                          size: 20,
                        ),
                        onTap: _notificationsEnabled
                            ? null
                            : () async {
                                await sl<NotificationService>().openNotificationSettings();
                                // Re-check permission when user returns
                                _checkNotificationPermission();
                              },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Security Section
                    _SectionHeader(label: 'Security'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.fingerprint,
                              color: _biometricsAvailable
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            title: Text('App Lock',
                                style: theme.textTheme.titleSmall),
                            subtitle: Text(
                              _biometricsAvailable
                                  ? _lockTimeoutLabel(state.appLockTimeout)
                                  : 'Not available',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _biometricsAvailable
                                    ? null
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                            trailing: _biometricsAvailable
                                ? const Icon(Icons.chevron_right, size: 20)
                                : null,
                            onTap: _biometricsAvailable
                                ? () => _showLockTimeoutDialog(context, state.appLockTimeout)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: Text(
                              _biometricsAvailable
                                  ? 'Uses your device\'s fingerprint, face unlock, or PIN/pattern to protect the app.'
                                  : 'Set up a screen lock (PIN, pattern, fingerprint, or face) in your device settings to enable this feature.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Currency Section
                    _SectionHeader(label: 'Currency'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Selected Currency', style: theme.textTheme.titleSmall),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${state.currencySymbol} (${state.currencyCode})',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Data Section
                    _SectionHeader(label: 'Data'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.download_outlined,
                                color: theme.colorScheme.primary),
                            title: Text('Export to CSV',
                                style: theme.textTheme.titleSmall),
                            subtitle: Text('Download all expenses as CSV',
                                style: theme.textTheme.bodySmall),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _exportCsv(context),
                          ),
                          Divider(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.1)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.category_outlined,
                                color: theme.colorScheme.primary),
                            title: Text('Manage Categories',
                                style: theme.textTheme.titleSmall),
                            subtitle: Text('Add or edit expense categories',
                                style: theme.textTheme.bodySmall),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoryManagementScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About
                    _SectionHeader(label: 'About'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trackr', style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                          const SizedBox(height: 4),
                          Text(
                            'Personal expense & task tracker.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version 1.0.0',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

        );
      },
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsState state) {
    final controller = TextEditingController(
      text: state.budgetAmount != null && state.budgetAmount! > 0
          ? state.budgetAmount!.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '${state.currencySymbol} ',
            hintText: 'Enter amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                context.read<SettingsCubit>().setBudget(amount);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final cubit = context.read<SettingsCubit>();
      final symbol = cubit.state.currencySymbol;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting...')),
      );

      final expenses = await sl<ExpenseRepository>().getFiltered(limit: 10000);
      final categories = await sl<CategoryRepository>().getAll();

      final dir = await getApplicationDocumentsDirectory();
      final path = await CsvExportService().exportExpenses(
        expenses: expenses,
        categories: categories,
        currencySymbol: symbol,
        directoryPath: dir.path,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)]),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  String _lockTimeoutLabel(String value) {
    switch (value) {
      case '0':
        return 'Immediately';
      case '60':
        return 'After 1 minute';
      case '300':
        return 'After 5 minutes';
      default:
        return 'Off';
    }
  }

  void _showLockTimeoutDialog(BuildContext context, String current) {
    const options = [
      ('off', 'Off', 'No lock — app opens freely'),
      ('0', 'Immediately', 'Lock every time you leave the app'),
      ('60', 'After 1 minute', 'Lock if away for more than 1 minute'),
      ('300', 'After 5 minutes', 'Lock if away for more than 5 minutes'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String selected = current;
          return AlertDialog(
            title: const Text('App Lock Timeout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                final (value, label, description) = opt;
                final isSelected = selected == value;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Theme.of(ctx).colorScheme.primary
                        : null,
                  ),
                  title: Text(label),
                  subtitle: Text(
                    description,
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    context.read<SettingsCubit>().setAppLockTimeout(value);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
