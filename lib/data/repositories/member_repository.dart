import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class MemberRepository {
  final FirebaseFirestore _firestore;

  MemberRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getMembersCollection(String groupId) {
    return _firestore
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .collection(AppConstants.membersCollection);
  }

  Stream<List<Member>> getMembers(String groupId) {
    return _getMembersCollection(groupId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList());
  }

  Future<Member> addMember({
    required String groupId,
    required String name,
    required String phoneNumber,
    String? bankingName,
    double? paymentAmount,
  }) async {
    final currentMonth = PaymentDateUtils.getCurrentPaymentMonth();
    final data = {
      'name': name,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
      'bankingName': bankingName,
      'paymentAmount': paymentAmount,
      'payments': {currentMonth: false},
      'paymentNotes': {},
      'forwarded': false,
    };

    final docRef = await _getMembersCollection(groupId).add(data);
    final doc = await docRef.get();
    return Member.fromFirestore(doc);
  }

  Future<void> updateMember(String groupId, Member member) async {
    await _getMembersCollection(groupId).doc(member.id).update(member.toMap());
  }

  Future<void> deleteMember(String groupId, String memberId) async {
    await _getMembersCollection(groupId).doc(memberId).delete();
  }

  Future<void> markPayment({
    required String groupId,
    required String memberId,
    required String month,
    required bool isPaid,
    String? note,
  }) async {
    final Map<String, dynamic> data = {
      'payments.$month': isPaid,
      'forwarded': false,
    };

    if (note != null) {
      data['paymentNotes.$month'] = note;
    } else if (!isPaid) {
      // Remove payment note if marking as unpaid
      data['paymentNotes.$month'] = FieldValue.delete();
    }

    await _getMembersCollection(groupId).doc(memberId).update(data);
  }

  Future<void> markForwarded({
    required String groupId,
    required List<String> memberIds,
  }) async {
    final batch = _firestore.batch();
    for (final memberId in memberIds) {
      final ref = _getMembersCollection(groupId).doc(memberId);
      batch.update(ref, {'forwarded': true});
    }
    await batch.commit();
  }

  Stream<List<Member>> getPendingMembers(String groupId, String month) {
    return _getMembersCollection(groupId)
        .where('payments.$month', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList());
  }

  Stream<List<Member>> getPaidUnforwardedMembers(String groupId, String month) {
    return _getMembersCollection(groupId)
        .where('payments.$month', isEqualTo: true)
        .where('forwarded', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList());
  }

  Future<void> addMonthToAllMembers(String month) async {
    // Get all groups
    final groups =
        await _firestore.collection(AppConstants.groupsCollection).get();

    // Update all members in all groups
    final batch = _firestore.batch();
    for (final group in groups.docs) {
      final members = await _getMembersCollection(group.id).get();
      for (final member in members.docs) {
        batch.update(member.reference, {'payments.$month': false});
      }
    }
    await batch.commit();
  }
}
