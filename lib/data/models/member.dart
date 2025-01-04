import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String phoneNumber;
  final String groupId;
  final String? bankingName;
  final double? paymentAmount;
  final Map<String, bool> payments;
  final Map<String, String> paymentNotes;
  final bool forwarded;

  Member({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.groupId,
    this.bankingName,
    this.paymentAmount,
    required this.payments,
    required this.paymentNotes,
    required this.forwarded,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    final payments = Map<String, bool>.from(data['payments'] ?? {});
    final paymentNotes = Map<String, String>.from(data['paymentNotes'] ?? {});

    return Member(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      groupId: data['groupId'] ?? '',
      bankingName: data['bankingName'],
      paymentAmount: (data['paymentAmount'] as num?)?.toDouble(),
      payments: payments,
      paymentNotes: paymentNotes,
      forwarded: data['forwarded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
      'bankingName': bankingName,
      'paymentAmount': paymentAmount,
      'payments': payments,
      'paymentNotes': paymentNotes,
      'forwarded': forwarded,
    };
  }

  bool isPaymentPending(String month) {
    return !(payments[month] ?? false);
  }

  String? getPaymentNote(String month) {
    return paymentNotes[month];
  }

  Member copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? groupId,
    String? bankingName,
    double? paymentAmount,
    Map<String, bool>? payments,
    Map<String, String>? paymentNotes,
    bool? forwarded,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupId: groupId ?? this.groupId,
      bankingName: bankingName ?? this.bankingName,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      payments: payments ?? Map.from(this.payments),
      paymentNotes: paymentNotes ?? Map.from(this.paymentNotes),
      forwarded: forwarded ?? this.forwarded,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $name, phoneNumber: $phoneNumber, '
        'groupId: $groupId, bankingName: $bankingName, '
        'paymentAmount: $paymentAmount, payments: $payments, '
        'paymentNotes: $paymentNotes, forwarded: $forwarded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Member &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.groupId == groupId &&
        other.bankingName == bankingName &&
        other.paymentAmount == paymentAmount &&
        other.forwarded == forwarded;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        groupId.hashCode ^
        bankingName.hashCode ^
        paymentAmount.hashCode ^
        forwarded.hashCode;
  }
}
