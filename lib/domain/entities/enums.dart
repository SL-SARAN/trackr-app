
enum TimeOfDayTag { morning, noon, evening, night }

extension TimeOfDayTagX on TimeOfDayTag {
  String get label {
    switch (this) {
      case TimeOfDayTag.morning:
        return 'Morning';
      case TimeOfDayTag.noon:
        return 'Noon';
      case TimeOfDayTag.evening:
        return 'Evening';
      case TimeOfDayTag.night:
        return 'Night';
    }
  }

  static TimeOfDayTag fromString(String value) {
    switch (value.toLowerCase()) {
      case 'morning':
        return TimeOfDayTag.morning;
      case 'noon':
        return TimeOfDayTag.noon;
      case 'evening':
        return TimeOfDayTag.evening;
      default:
        return TimeOfDayTag.night;
    }
  }
}

enum ImportanceLevel { low, medium, high }

extension ImportanceLevelX on ImportanceLevel {
  String get label {
    switch (this) {
      case ImportanceLevel.low:
        return 'Low';
      case ImportanceLevel.medium:
        return 'Medium';
      case ImportanceLevel.high:
        return 'High';
    }
  }

  String get value {
    switch (this) {
      case ImportanceLevel.low:
        return 'low';
      case ImportanceLevel.medium:
        return 'medium';
      case ImportanceLevel.high:
        return 'high';
    }
  }

  static ImportanceLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return ImportanceLevel.high;
      case 'low':
        return ImportanceLevel.low;
      default:
        return ImportanceLevel.medium;
    }
  }
}

enum RecurrenceType { none, daily, weekly, monthly, yearly }

extension RecurrenceTypeX on RecurrenceType {
  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  String get value => name;

  static RecurrenceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return RecurrenceType.daily;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'monthly':
        return RecurrenceType.monthly;
      case 'yearly':
        return RecurrenceType.yearly;
      default:
        return RecurrenceType.none;
    }
  }
}
