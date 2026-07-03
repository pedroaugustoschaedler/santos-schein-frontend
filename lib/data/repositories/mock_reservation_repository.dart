import '../../domain/repositories/i_reservation_repository.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/reservation.dart';

class MockReservationRepository implements IReservationRepository {
  @override
  Future<List<CourtEntity>> getCourts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      CourtEntity(id: "1", name: "Quadra 1", sportType: "Tênis", isActive: true),
      CourtEntity(id: "2", name: "Quadra 2", sportType: "Beach Tennis", isActive: true),
      CourtEntity(id: "3", name: "Quadra 3", sportType: "Futsal", isActive: true),
      CourtEntity(id: "4", name: "Quadra 4", sportType: "Vôlei", isActive: true),
    ];
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots(String courtId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final times = [
      "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00",
      "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"
    ];

    final days = ["sex", "sab", "dom", "seg", "ter", "qua", "qui"];
    List<TimeSlot> slots = [];

    for (var day in days) {
      for (var time in times) {
        bool isAvailable = true;
        if (day == "sab" || day == "dom") {
          isAvailable = false;
        } else if (day == "sex" && (time == "14:30" || time == "15:00" || time == "19:00")) {
          isAvailable = false;
        }
        slots.add(TimeSlot(dayKey: day, time: time, isAvailable: isAvailable));
      }
    }

    return slots;
  }

  @override
  Future<bool> createReservation(String userId, String courtId, String date, String startTime, int durationMinutes) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<List<Reservation>> getUserReservations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Reservation(
        id: "1",
        courtName: "Quadra 1",
        date: "07/07/2026",
        time: "19:00",
        status: "CONFIRMED",
      ),
    ];
  }
}
