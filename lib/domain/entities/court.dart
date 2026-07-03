class CourtEntity {
  final String id;
  final String name;
  final String sportType;
  final bool isActive;

  CourtEntity({
    required this.id,
    required this.name,
    required this.sportType,
    required this.isActive,
  });

  factory CourtEntity.fromJson(Map<String, dynamic> json) {
    return CourtEntity(
      id: json['id'].toString(),
      name: json['name'],
      sportType: json['sportType'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
