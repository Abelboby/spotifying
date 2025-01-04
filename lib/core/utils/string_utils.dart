class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalize).join(' ');
  }

  static String formatPhoneNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return number;
    return '${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static bool isValidPhoneNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 10 && RegExp(r'^[0-9]+$').hasMatch(cleaned);
  }

  static bool isValidAmount(String amount) {
    return RegExp(r'^\d+\.?\d{0,2}$').hasMatch(amount);
  }
}
