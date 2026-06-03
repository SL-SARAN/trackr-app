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
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: 'Add Expense'),
              Tab(text: 'Add Task'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _ExpenseForm(currencySymbol: widget.currencySymbol),
            const _TaskForm(),
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
                        : const Text('Add Expense'),
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
        );
    _amountCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
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
