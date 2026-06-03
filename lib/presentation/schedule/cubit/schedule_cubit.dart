import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../domain/entities/enums.dart';
import '../../../services/notification_service.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ExpenseRepository _expenses;
  final TaskRepository _tasks;
  final CategoryRepository _categories;
  final NotificationService _notifications;

  ScheduleCubit({
    required ExpenseRepository expenses,
    required TaskRepository tasks,
    required CategoryRepository categories,
    required NotificationService notifications,
  })  : _expenses = expenses,
        _tasks = tasks,
        _categories = categories,
        _notifications = notifications,
        super(const ScheduleState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final cats = await _categories.getAll();
      emit(state.copyWith(status: ScheduleStatus.initial, categories: cats));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.error, error: e.toString()));
    }
  }

  Future<void> addExpense({
    required double amount,
    required int categoryId,
    String? description,
    required DateTime date,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.saving));
    try {
      await _expenses.create(
        amount: amount,
        categoryId: categoryId,
        description: description,
        date: date,
      );
      emit(state.copyWith(status: ScheduleStatus.saved));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.error, error: e.toString()));
    }
  }

  Future<void> addTask({
    required String title,
    String? description,
    required ImportanceLevel importance,
    required DateTime scheduledAt,
    required bool isRecurring,
    required RecurrenceType recurrenceType,
    required bool isPlannedExpense,
    double? estimatedAmount,
    int? categoryId,
    int? reminderMinutes,
    bool notifyAtTaskTime = false,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.saving, permissionDenied: false));
    try {
      // Generate a unique notification ID
      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000 +
          Random().nextInt(10000);

      await _tasks.create(
        title: title,
        description: description,
        importance: importance,
        scheduledAt: scheduledAt,
        isRecurring: isRecurring,
        recurrenceType: recurrenceType,
        isPlannedExpense: isPlannedExpense,
        estimatedAmount: estimatedAmount,
        categoryId: categoryId,
        notificationId: notificationId,
      );

      // Check and request notification permission before scheduling
      if (scheduledAt.isAfter(DateTime.now())) {
        bool hasPermission = await _notifications.hasPermission();

        if (!hasPermission) {
          hasPermission = await _notifications.requestPermission();
        }

        if (!hasPermission) {
          // Permission denied — check if permanently denied
          final permanentlyDenied = await _notifications.isPermanentlyDenied();
          if (permanentlyDenied) {
            emit(state.copyWith(
              status: ScheduleStatus.saved,
              permissionDenied: true,
            ));
            return;
          }
          // Not permanently denied but still denied — save task but skip notification
          emit(state.copyWith(status: ScheduleStatus.saved));
          return;
        }

        // Permission granted — schedule reminder notification (default 15 min before)
        final reminderTime = scheduledAt.subtract(
          Duration(minutes: reminderMinutes ?? 15),
        );

        if (reminderTime.isAfter(DateTime.now())) {
          await _notifications.scheduleTask(
            id: notificationId,
            title: 'Trackr Reminder',
            body: title,
            scheduledAt: reminderTime,
          );
        }

        // Schedule additional notification at exact task time if requested
        if (notifyAtTaskTime && scheduledAt.isAfter(DateTime.now())) {
          final exactTimeNotifId = notificationId + 1;
          await _notifications.scheduleTask(
            id: exactTimeNotifId,
            title: 'Trackr — Task Now',
            body: title,
            scheduledAt: scheduledAt,
          );
        }
      }

      emit(state.copyWith(status: ScheduleStatus.saved));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.error, error: e.toString()));
    }
  }

  /// Open the app's notification settings (for permanently denied recovery).
  Future<void> openNotificationSettings() async {
    await _notifications.openNotificationSettings();
  }

  void resetStatus() {
    emit(state.copyWith(status: ScheduleStatus.initial, permissionDenied: false));
  }
}

