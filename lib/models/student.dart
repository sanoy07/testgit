class Student {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime joinDate;
  final String roomId;
  final bool isActive;

  Student({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.joinDate,
    required this.roomId,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'joinDate': joinDate.toIso8601String(),
      'roomId': roomId,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      joinDate: DateTime.parse(map['joinDate']),
      roomId: map['roomId'],
      isActive: map['isActive'] == 1,
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    DateTime? joinDate,
    String? roomId,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      roomId: roomId ?? this.roomId,
      isActive: isActive ?? this.isActive,
    );
  }
}