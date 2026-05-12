import '../constants/app_constants.dart';
import '../../domain/entities/enums.dart';

class DateHelper {
  DateHelper._();

  /// Returns the time-of-day tag for a given [DateTime].
  static TimeOfDayTag timeOfDayTag(DateTime dt) {
    final hour = dt.hour;
    if (hour >= AppConstants.morningStart && hour < AppConstants.noonStart) {
      return TimeOfDayTag.morning;
    } else if (hour >= AppConstants.noonStart && hour < AppConstants.eveningStart) {
      return TimeOfDayTag.noon;
    } else if (hour >= AppConstants.eveningStart && hour < AppConstants.nightStart) {
      return TimeOfDayTag.evening;
    } else {
      return TimeOfDayTag.night;
    }
  }

  /// String value stored in the DB.
  static String timeOfDayTagString(DateTime dt) =>
      timeOfDayTag(dt).name;

  /// Start of the current calendar month.
  static DateTime startOfMonth([DateTime? reference]) {
    final d = reference ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  /// End of the current calendar month (exclusive — first moment of next month).
  static DateTime endOfMonth([DateTime? reference]) {
    final d = reference ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 1);
  }

  /// Start of the day (00:00:00).
  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// End of the day (exclusive — first moment of next day).
  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day + 1);

  /// Returns true if two DateTimes fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
