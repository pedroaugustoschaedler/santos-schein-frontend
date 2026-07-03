import 'package:dio/dio.dart';
import '../../domain/repositories/i_reservation_repository.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/reservation.dart';

class ApiReservationRepository implements IReservationRepository {
  final Dio _dio;

  ApiReservationRepository(this._dio);

  /// Busca todas as quadras disponíveis
  @override
  Future<List<CourtEntity>> getCourts() async {
    try {
      final response = await _dio.get('/api/courts');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => CourtEntity.fromJson(json)).toList();
      }
      throw Exception('Erro de servidor (Status ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  /// Busca os slots de horários disponíveis para uma quadra na semana
  @override
  Future<List<TimeSlot>> getAvailableSlots(String courtId, DateTime date) async {
    try {
      // Formata a data para yyyy-MM-dd
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await _dio.get(
        '/api/reservations/slots',
        queryParameters: {
          'courtId': courtId,
          'weekStart': dateStr,
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => TimeSlot.fromJson(json)).toList();
      }
      throw Exception('Erro de servidor ao buscar horários');
    } catch (e) {
      rethrow;
    }
  }

  /// Cria reserva
  @override
  Future<bool> createReservation(String userId, String courtId, String date, String startTime, int durationMinutes) async {
    try {
      final response = await _dio.post(
        '/api/reservations',
        data: {
          'userId': userId,
          'courtId': courtId,
          'date': date,
          'startTime': startTime,
          'durationMinutes': durationMinutes,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
      throw Exception(response.data ?? 'Erro ao criar reserva');
    } catch (e) {
      rethrow;
    }
  }

  /// Busca reservas do usuário
  @override
  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      final response = await _dio.get('/api/reservations/user/$userId');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => Reservation.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar reservas do usuário');
    } catch (e) {
      rethrow;
    }
  }
}
