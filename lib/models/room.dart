class Room {
  final String id;
  final String number;
  final String buildingId;
  final int capacity;
  final int currentOccupancy;

  Room({
    required this.id,
    required this.number,
    required this.buildingId,
    required this.capacity,
    this.currentOccupancy = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'buildingId': buildingId,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      number: map['number'],
      buildingId: map['buildingId'],
      capacity: map['capacity'],
      currentOccupancy: map['currentOccupancy'] ?? 0,
    );
  }

  Room copyWith({
    String? id,
    String? number,
    String? buildingId,
    int? capacity,
    int? currentOccupancy,
  }) {
    return Room(
      id: id ?? this.id,
      number: number ?? this.number,
      buildingId: buildingId ?? this.buildingId,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
    );
  }

  bool get isAvailable => currentOccupancy < capacity;
  int get availableSpots => capacity - currentOccupancy;
}