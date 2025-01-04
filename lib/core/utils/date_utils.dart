import '../constants/app_constants.dart';

class PaymentDateUtils {
  static String getCurrentPaymentMonth() {
    final now = DateTime.now();
    if (now.day < 20) {
      // If before 20th, use previous month
      final prevMonth = DateTime(now.year, now.month - 1);
      return '${prevMonth.year}-${prevMonth.month.toString().padLeft(2, '0')}';
    }
    // If 20th or later, use current month
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static String formatYearMonth(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  static String getNextMonth(String currentMonth) {
    final parts = currentMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    if (month == 12) {
      return formatYearMonth(year + 1, 1);
    }
    return formatYearMonth(year, month + 1);
  }

  static String getPreviousMonth(String currentMonth) {
    final parts = currentMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    if (month == 1) {
      return formatYearMonth(year - 1, 12);
    }
    return formatYearMonth(year, month - 1);
  }

  static String formatUptime(double minutes) {
    if (minutes < 1) return 'Just started';
    if (minutes < 60) return '${minutes.round()} minutes';
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();
    if (remainingMinutes == 0) return '$hours hours';
    return '$hours hours $remainingMinutes minutes';
  }

  static DateTime parseSmsDate(String dateStr) {
    // Format: ddMmmyy (e.g., 26Dec24)
    final day = int.parse(dateStr.substring(0, 2));
    final month = _parseMonth(dateStr.substring(2, 5));
    final year = 2000 + int.parse(dateStr.substring(5));
    return DateTime(year, month, day);
  }

  static int _parseMonth(String monthStr) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };
    return months[monthStr] ?? 1;
  }

  static DateTimeRange getMonthDateRange(String month) {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);

    // For the selected month (e.g., December), start from 20th of previous month
    final start = DateTime(
      monthNum == 1 ? year - 1 : year, // Previous year if January
      monthNum == 1 ? 12 : monthNum - 1, // December if January
      20,
    );

    // End on 19th of current month
    final end = DateTime(year, monthNum, 19, 23, 59, 59);

    return DateTimeRange(start: start, end: end);
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}
