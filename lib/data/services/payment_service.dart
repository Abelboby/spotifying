import '../models/member.dart';
import '../repositories/member_repository.dart';
import 'sms_service.dart';
import '../../core/utils/date_utils.dart';

class PaymentService {
  final MemberRepository _memberRepository;
  final SMSService _smsService;

  PaymentService({
    required MemberRepository memberRepository,
    required SMSService smsService,
  })  : _memberRepository = memberRepository,
        _smsService = smsService;

  Future<void> processAutomaticPayments(String groupId, String month) async {
    final members =
        await _memberRepository.getPendingMembers(groupId, month).first;

    final messages = await _smsService.getMessagesForMonth(month);

    for (final message in messages) {
      if (message.body == null) continue;

      final bankingName =
          _smsService.extractBankingNameFromMessage(message.body!);
      if (bankingName == null) continue;

      final amount = _smsService.extractAmountFromMessage(message.body!);
      if (amount == null) continue;

      final date = _smsService.extractDateFromMessage(message.body!);
      if (date == null) continue;

      // Find matching member
      final matchingMember = members.firstWhere(
        (member) =>
            member.bankingName?.toLowerCase() == bankingName.toLowerCase() &&
            member.paymentAmount == amount,
        orElse: () => throw Exception('No matching member found'),
      );

      // Mark payment as received
      await _memberRepository.markPayment(
        groupId: groupId,
        memberId: matchingMember.id,
        month: month,
        isPaid: true,
        note: 'Auto-marked from SMS on ${date.day}/${date.month}/${date.year}',
      );
    }
  }

  Future<void> markPayment({
    required String groupId,
    required String memberId,
    required String month,
    required bool isPaid,
    String? note,
  }) async {
    await _memberRepository.markPayment(
      groupId: groupId,
      memberId: memberId,
      month: month,
      isPaid: isPaid,
      note: note,
    );
  }

  Future<void> markForwarded({
    required String groupId,
    required List<String> memberIds,
  }) async {
    await _memberRepository.markForwarded(
      groupId: groupId,
      memberIds: memberIds,
    );
  }

  Future<void> addNewMonth() async {
    final currentMonth = PaymentDateUtils.getCurrentPaymentMonth();
    await _memberRepository.addMonthToAllMembers(currentMonth);
  }
}
