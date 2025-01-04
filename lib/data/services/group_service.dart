import '../models/group.dart';
import '../repositories/group_repository.dart';
import '../repositories/member_repository.dart';

class GroupService {
  final GroupRepository _groupRepository;
  final MemberRepository _memberRepository;

  GroupService({
    required GroupRepository groupRepository,
    required MemberRepository memberRepository,
  })  : _groupRepository = groupRepository,
        _memberRepository = memberRepository;

  Stream<List<Group>> getGroups() {
    return _groupRepository.getGroups();
  }

  Future<Group> createGroup(String name) async {
    return await _groupRepository.createGroup(name);
  }

  Future<void> updateGroup(Group group) async {
    await _groupRepository.updateGroup(group);
  }

  Future<void> deleteGroup(String groupId) async {
    // Get all members in the group
    final members = await _memberRepository.getMembers(groupId).first;

    // Delete all members first
    for (final member in members) {
      await _memberRepository.deleteMember(groupId, member.id);
    }

    // Then delete the group
    await _groupRepository.deleteGroup(groupId);
  }

  Stream<Group> watchGroup(String groupId) {
    return _groupRepository.watchGroup(groupId);
  }

  Future<Map<String, int>> getPendingPaymentCounts() async {
    final groups = await _groupRepository.getGroups().first;
    final Map<String, int> counts = {};

    for (final group in groups) {
      final members = await _memberRepository.getMembers(group.id).first;
      if (members.isEmpty) {
        counts[group.id] = 0;
        continue;
      }

      // Get the payment status for the current month from the first member
      final currentMonth = members.first.payments.keys.last;
      final pendingCount = members
          .where((member) => member.isPaymentPending(currentMonth))
          .length;
      counts[group.id] = pendingCount;
    }

    return counts;
  }
}
