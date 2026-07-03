import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/i_reservation_repository.dart';
import '../../data/repositories/api_reservation_repository.dart';
import '../../data/repositories/mock_reservation_repository.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Configure Dio Client
  final dio = Dio(BaseOptions(
    baseUrl: 'https://santos-schein-api.onrender.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  sl.registerLazySingleton<Dio>(() => dio);

  // MUDAR AQUI PARA CHAVEAR ENTRE API REAL E MOCK
  const bool useApi = true; 

  if (useApi) {
    sl.registerLazySingleton<IReservationRepository>(() => ApiReservationRepository(sl<Dio>()));
  } else {
    sl.registerLazySingleton<IReservationRepository>(() => MockReservationRepository());
  }
}
