class TimeSlot {
  final String dayKey;
  final String time;
  final bool isAvailable;

  TimeSlot({
    required this.dayKey,
    required this.time,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      dayKey: json['dayKey'],
      time: json['time'],
      isAvailable: json['isAvailable'],
    );
  }
}
