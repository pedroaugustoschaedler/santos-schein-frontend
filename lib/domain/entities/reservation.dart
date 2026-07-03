class Reservation {
  final String id;
  final String courtName;
  final String date;
  final String time;
  final String status; // 'CONFIRMED', 'PENDING', 'CANCELLED'

  Reservation({
    required this.id,
    required this.courtName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      courtName: json['courtName'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
    );
  }
}
