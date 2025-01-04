import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import '../../core/constants/app_constants.dart';

class GroupRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference _groupsCollection;

  GroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _groupsCollection = (firestore ?? FirebaseFirestore.instance)
            .collection(AppConstants.groupsCollection);

  Stream<List<Group>> getGroups() {
    return _groupsCollection
        .orderBy('groupName', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList());
  }

  Future<Group> createGroup(String name) async {
    final docRef = await _groupsCollection.add({'groupName': name});
    final doc = await docRef.get();
    return Group.fromFirestore(doc);
  }

  Future<void> updateGroup(Group group) async {
    await _groupsCollection.doc(group.id).update(group.toMap());
  }

  Future<void> deleteGroup(String groupId) async {
    await _groupsCollection.doc(groupId).delete();
  }

  Future<Group?> getGroup(String groupId) async {
    final doc = await _groupsCollection.doc(groupId).get();
    if (!doc.exists) return null;
    return Group.fromFirestore(doc);
  }

  Stream<Group> watchGroup(String groupId) {
    return _groupsCollection
        .doc(groupId)
        .snapshots()
        .map((doc) => Group.fromFirestore(doc));
  }
}
