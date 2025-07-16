enum FeeRecurrence { monthly, quarterly, yearly }

class FeeStructure {
  final String id;
  final String? buildingId;
  final double amount;
  final FeeRecurrence recurrence;
  final DateTime startDate;

  FeeStructure({
    required this.id,
    this.buildingId,
    required this.amount,
    required this.recurrence,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buildingId': buildingId,
      'amount': amount,
      'recurrence': recurrence.name,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory FeeStructure.fromMap(Map<String, dynamic> map) {
    return FeeStructure(
      id: map['id'],
      buildingId: map['buildingId'],
      amount: map['amount'],
      recurrence: FeeRecurrence.values.firstWhere((e) => e.name == map['recurrence']),
      startDate: DateTime.parse(map['startDate']),
    );
  }

  FeeStructure copyWith({
    String? id,
    String? buildingId,
    double? amount,
    FeeRecurrence? recurrence,
    DateTime? startDate,
  }) {
    return FeeStructure(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      amount: amount ?? this.amount,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
    );
  }

  DateTime getNextDueDate(DateTime lastDueDate) {
    switch (recurrence) {
      case FeeRecurrence.monthly:
        return DateTime(lastDueDate.year, lastDueDate.month + 1, lastDueDate.day);
      case FeeRecurrence.quarterly:
        return DateTime(lastDueDate.year, lastDueDate.month + 3, lastDueDate.day);
      case FeeRecurrence.yearly:
        return DateTime(lastDueDate.year + 1, lastDueDate.month, lastDueDate.day);
    }
  }

  String get recurrenceText {
    switch (recurrence) {
      case FeeRecurrence.monthly:
        return 'Monthly';
      case FeeRecurrence.quarterly:
        return 'Quarterly';
      case FeeRecurrence.yearly:
        return 'Yearly';
    }
  }
}