import 'package:telephony/telephony.dart';
import '../../core/utils/date_utils.dart';

class SMSService {
  final Telephony _telephony;

  SMSService({Telephony? telephony})
      : _telephony = telephony ?? Telephony.instance;

  Future<List<SmsMessage>> getMessagesForMonth(String month) async {
    final dateRange = PaymentDateUtils.getMonthDateRange(month);
    final messages = await _telephony.getInboxSms();

    return messages.where((msg) {
      if (msg.address?.contains('SBIUPI') != true) return false;

      final timestamp = msg.date ?? 0;
      final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return messageDate.isAfter(dateRange.start) &&
          messageDate.isBefore(dateRange.end);
    }).toList();
  }

  Future<bool> requestSmsPermission() async {
    return await _telephony.requestSmsPermissions ?? false;
  }

  String? extractBankingNameFromMessage(String message) {
    final regex = RegExp(r'transfer from ([A-Za-z\s]+) Ref No');
    final match = regex.firstMatch(message);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim();
    }
    return null;
  }

  double? extractAmountFromMessage(String message) {
    final regex = RegExp(r'Rs\.(\d+)');
    final match = regex.firstMatch(message);
    if (match != null && match.groupCount >= 1) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  DateTime? extractDateFromMessage(String message) {
    final regex = RegExp(r'on (\d{2}[A-Za-z]{3}\d{2})');
    final match = regex.firstMatch(message);
    if (match != null && match.groupCount >= 1) {
      final dateStr = match.group(1);
      if (dateStr != null) {
        try {
          return PaymentDateUtils.parseSmsDate(dateStr);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }
}
