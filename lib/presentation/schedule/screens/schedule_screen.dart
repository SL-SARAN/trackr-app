import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/enums.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';

class ScheduleScreen extends StatefulWidget {
  final String currencySymbol;
  const ScheduleScreen({super.key, required this.currencySymbol});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ScheduleCubit>().loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ScheduleCubit, ScheduleState>(
      listener: (context, state) {
        if (state.status == ScheduleStatus.saved && state.permissionDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Notification permission denied. Task saved without reminder.',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () {
                  context.read<ScheduleCubit>().openNotificationSettings();
                },
              ),
            ),
          );
          context.read<ScheduleCubit>().resetStatus();
        } else if (state.status == ScheduleStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Saved successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<ScheduleCubit>().resetStatus();
        }
        if (state.status == ScheduleStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Schedule',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Add Entry'),
              Tab(text: 'Add Task'),
              Tab(text: 'Recurring'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _ExpenseForm(currencySymbol: widget.currencySymbol),
            const _TaskForm(),
            _RecurringTab(currencySymbol: widget.currencySymbol),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Form ────────────────────────────────────────────────────────────

class _ExpenseForm extends StatefulWidget {
  final String currencySymbol;
  const _ExpenseForm({required this.currencySymbol});

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'debit';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        final categories = state.categories;
        final isSaving = state.status == ScheduleStatus.saving;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense or Income Toggle
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'debit', label: Text('Expense')),
                      ButtonSegment(value: 'credit', label: Text('Income')),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (s) => setState(() => _selectedType = s.first),
                  ),
                ).animate().fadeIn(duration: 300.ms),
                
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${widget.currencySymbol} ',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter amount';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .where((c) => c.type == _selectedType)
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: c.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) => v == null ? 'Select a category' : null,
                ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                const SizedBox(height: 16),

                // Date & Time row
                Row(
                  children: [
                    Expanded(
                      child: _DateTimePicker(
                        label: 'Date',
                        value: DateFormat('MMM d, yyyy').format(_selectedDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                                const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateTimePicker(
                        label: 'Time',
                        value: _selectedTime.format(context),
                        icon: Icons.access_time_outlined,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) {
                            setState(() => _selectedTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                const SizedBox(height: 28),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_selectedType == 'credit' ? 'Add Income' : 'Add Expense'),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    context.read<ScheduleCubit>().addExpense(
          amount: double.parse(_amountCtrl.text.trim()),
          categoryId: _selectedCategoryId!,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          date: date,
          type: _selectedType,
        );
    _amountCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedType = 'debit';
    });
  }
}

// ─── Task Form ───────────────────────────────────────────────────────────────

class _TaskForm extends StatefulWidget {
  const _TaskForm();

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  ImportanceLevel _importance = ImportanceLevel.medium;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();
  bool _isRecurring = false;
  RecurrenceType _recurrence = RecurrenceType.none;
  bool _isPlannedExpense = false;
  bool _notifyAtTaskTime = false;
  int? _categoryId;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        final categories = state.categories;
        final isSaving = state.status == ScheduleStatus.saving;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a title' : null,
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

                const SizedBox(height: 16),

                // Importance
                Text('Importance', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                SegmentedButton<ImportanceLevel>(
                  segments: ImportanceLevel.values
                      .map((level) => ButtonSegment(
                            value: level,
                            label: Text(level.label),
                          ))
                      .toList(),
                  selected: {_importance},
                  onSelectionChanged: (s) =>
                      setState(() => _importance = s.first),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                const SizedBox(height: 16),

                // Scheduled Date & Time
                Row(
                  children: [
                    Expanded(
                      child: _DateTimePicker(
                        label: 'Date',
                        value:
                            DateFormat('MMM d, yyyy').format(_scheduledDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _scheduledDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 730)),
                          );
                          if (picked != null) {
                            setState(() => _scheduledDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateTimePicker(
                        label: 'Time',
                        value: _scheduledTime.format(context),
                        icon: Icons.access_time_outlined,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _scheduledTime,
                          );
                          if (picked != null) {
                            setState(() => _scheduledTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                const SizedBox(height: 16),

                // Recurrence toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Recurring', style: theme.textTheme.titleSmall),
                  value: _isRecurring,
                  onChanged: (v) => setState(() {
                    _isRecurring = v;
                    if (!v) _recurrence = RecurrenceType.none;
                  }),
                ).animate().fadeIn(duration: 300.ms, delay: 175.ms),

                if (_isRecurring) ...[
                  DropdownButtonFormField<RecurrenceType>(
                    initialValue: _recurrence == RecurrenceType.none
                        ? RecurrenceType.daily
                        : _recurrence,
                    decoration:
                        const InputDecoration(labelText: 'Repeat Every'),
                    items: RecurrenceType.values
                        .where((r) => r != RecurrenceType.none)
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _recurrence = v ?? RecurrenceType.daily),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notify at task time toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Notify at task time',
                      style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    'Also send a notification at the exact scheduled time',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: _notifyAtTaskTime,
                  onChanged: (v) => setState(() => _notifyAtTaskTime = v),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                // Planned expense toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title:
                      Text('Planned Expense', style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    'Auto-create expense when marked done',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: _isPlannedExpense,
                  onChanged: (v) => setState(() => _isPlannedExpense = v),
                ).animate().fadeIn(duration: 300.ms, delay: 225.ms),

                if (_isPlannedExpense) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Estimated Amount'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: c.color,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _categoryId = v),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 12),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Schedule Task'),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final scheduledAt = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );
    context.read<ScheduleCubit>().addTask(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          importance: _importance,
          scheduledAt: scheduledAt,
          isRecurring: _isRecurring,
          recurrenceType: _isRecurring ? _recurrence : RecurrenceType.none,
          isPlannedExpense: _isPlannedExpense,
          estimatedAmount: _isPlannedExpense
              ? double.tryParse(_amountCtrl.text.trim())
              : null,
          categoryId: _isPlannedExpense ? _categoryId : null,
          notifyAtTaskTime: _notifyAtTaskTime,
        );
    _titleCtrl.clear();
    _descCtrl.clear();
    _amountCtrl.clear();
    setState(() {
      _importance = ImportanceLevel.medium;
      _scheduledDate = DateTime.now();
      _scheduledTime = TimeOfDay.now();
      _isRecurring = false;
      _recurrence = RecurrenceType.none;
      _isPlannedExpense = false;
      _notifyAtTaskTime = false;
      _categoryId = null;
    });
  }
}

// ─── Shared Helper Widget ────────────────────────────────────────────────────

class _DateTimePicker extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimePicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, size: 18),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(value, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}

// ─── Recurring Tab ───────────────────────────────────────────────────────────

class _RecurringTab extends StatelessWidget {
  final String currencySymbol;
  const _RecurringTab({required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        final items = state.recurringExpenses;

        return Column(
          children: [
            if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No recurring expenses yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final category = state.categories.cast<dynamic>().firstWhere(
                          (c) => c.id == item.categoryId,
                          orElse: () => null,
                        );

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (category != null)
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: theme.textTheme.titleMedium),
                                Text(
                                  'Repeats ${item.frequency}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$currencySymbol ${item.amount.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.autoLog ? 'Auto-log' : 'Remind only',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showAddRecurringSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Recurring Expense'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddRecurringSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddRecurringSheet(
        currencySymbol: currencySymbol,
        cubit: context.read<ScheduleCubit>(),
      ),
    );
  }
}

class _AddRecurringSheet extends StatefulWidget {
  final String currencySymbol;
  final ScheduleCubit cubit;

  const _AddRecurringSheet({required this.currencySymbol, required this.cubit});

  @override
  State<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends State<_AddRecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int? _categoryId;
  String _frequency = 'monthly';
  DateTime _nextDueDate = DateTime.now();
  bool _autoLog = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Recurring Expense', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v!.isEmpty ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8, top: 14),
                  child: Text(widget.currencySymbol, style: theme.textTheme.bodyLarge),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<ScheduleCubit, ScheduleState>(
              bloc: widget.cubit,
              builder: (context, state) {
                return DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: state.categories
                      .where((c) => c.type == 'debit') // Recurring items are currently expenses only
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Select category' : null,
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateTimePicker(
                    label: 'Next Due Date',
                    value: DateFormat('MMM d, yyyy').format(_nextDueDate),
                    icon: Icons.calendar_today,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _nextDueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _nextDueDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-log expense'),
              subtitle: const Text('Automatically add expense on due date'),
              value: _autoLog,
              onChanged: (v) => setState(() => _autoLog = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.cubit.addRecurring(
        title: _titleCtrl.text.trim(),
        amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        categoryId: _categoryId!,
        frequency: _frequency,
        nextDueDate: _nextDueDate,
        autoLog: _autoLog,
      );
      Navigator.pop(context);
    }
  }
}
