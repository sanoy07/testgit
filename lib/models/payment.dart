enum PaymentStatus { paid, unpaid }

class Payment {
  final String id;
  final String studentId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final String? note;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'note': note,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      studentId: map['studentId'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['dueDate']),
      paidDate: map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
      status: PaymentStatus.values.firstWhere((e) => e.name == map['status']),
      note: map['note'],
    );
  }

  Payment copyWith({
    String? id,
    String? studentId,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    PaymentStatus? status,
    String? note,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  bool get isPaid => status == PaymentStatus.paid;
  bool get isOverdue => status == PaymentStatus.unpaid && DateTime.now().isAfter(dueDate);
}