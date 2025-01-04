import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;

  Group({
    required this.id,
    required this.name,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Group(
      id: doc.id,
      name: data?['groupName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupName': name,
    };
  }

  Group copyWith({
    String? id,
    String? name,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'Group(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
