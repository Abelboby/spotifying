import '../models/member.dart';
import '../repositories/member_repository.dart';
import '../../core/utils/date_utils.dart';

class MemberService {
  final MemberRepository _memberRepository;

  MemberService({
    required MemberRepository memberRepository,
  }) : _memberRepository = memberRepository;

  Stream<List<Member>> getMembers(String groupId) {
    return _memberRepository.getMembers(groupId);
  }

  Future<Member> addMember({
    required String groupId,
    required String name,
    required String phoneNumber,
    String? bankingName,
    double? paymentAmount,
  }) async {
    return await _memberRepository.addMember(
      groupId: groupId,
      name: name,
      phoneNumber: phoneNumber,
      bankingName: bankingName,
      paymentAmount: paymentAmount,
    );
  }

  Future<void> updateMember(String groupId, Member member) async {
    await _memberRepository.updateMember(groupId, member);
  }

  Future<void> deleteMember(String groupId, String memberId) async {
    await _memberRepository.deleteMember(groupId, memberId);
  }

  Stream<List<Member>> getPendingMembers(String groupId, String month) {
    return _memberRepository.getPendingMembers(groupId, month);
  }

  Stream<List<Member>> getPaidUnforwardedMembers(String groupId, String month) {
    return _memberRepository.getPaidUnforwardedMembers(groupId, month);
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

  Future<List<String>> getAvailableMonths(String groupId) async {
    final members = await getMembers(groupId).first;
    if (members.isEmpty) {
      final currentMonth = PaymentDateUtils.getCurrentPaymentMonth();
      return [currentMonth];
    }

    // Get all months from the first member's payments
    final months = members.first.payments.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort in descending order
    return months;
  }
}
