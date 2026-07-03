import '../entities/time_slot.dart';
import '../entities/court.dart';
import '../entities/reservation.dart';

abstract class IReservationRepository {
  Future<List<CourtEntity>> getCourts();
  Future<List<TimeSlot>> getAvailableSlots(String courtId, DateTime date);
  Future<bool> createReservation(String userId, String courtId, String date, String startTime, int durationMinutes);
  Future<List<Reservation>> getUserReservations(String userId);
}
