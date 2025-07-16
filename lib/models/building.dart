class Building {
  final String id;
  final String name;
  final String? address;

  Building({
    required this.id,
    required this.name,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      id: map['id'],
      name: map['name'],
      address: map['address'],
    );
  }

  Building copyWith({
    String? id,
    String? name,
    String? address,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}