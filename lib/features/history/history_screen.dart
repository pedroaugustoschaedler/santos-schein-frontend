import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/i_reservation_repository.dart';
import '../../domain/entities/reservation.dart';
import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final repository = sl<IReservationRepository>();
  List<Reservation> reservations = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await repository.getUserReservations(widget.userId);
      setState(() {
        reservations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "CONFIRMED":
        return AppTheme.accentColor;
      case "PENDING":
        return const Color(0xFFFFC107);
      case "CANCELLED":
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "CONFIRMED":
        return "Confirmada";
      case "PENDING":
        return "Pendente";
      case "CANCELLED":
        return "Cancelada";
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "CONFIRMED":
        return Icons.check_circle_outline;
      case "PENDING":
        return Icons.hourglass_top;
      case "CANCELLED":
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Minhas Reservas",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Histórico e reservas futuras",
                        style: TextStyle(fontSize: 13, color: Colors.white38),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.accentColor),
                    onPressed: _loadHistory,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
                                const SizedBox(height: 12),
                                const Text(
                                  "Não foi possível carregar o histórico.",
                                  style: TextStyle(color: Colors.white60, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadHistory,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Tentar novamente"),
                                ),
                              ],
                            ),
                          )
                        : reservations.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nenhuma reserva encontrada.",
                                  style: TextStyle(color: Colors.white38),
                                ),
                              )
                            : ListView.separated(
                            itemCount: reservations.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final r = reservations[i];
                              final color = _statusColor(r.status);
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_statusIcon(r.status), color: color, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.courtName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 11, color: Colors.white38),
                                              const SizedBox(width: 4),
                                              Text(r.date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.access_time, size: 11, color: Colors.white38),
                                              const SizedBox(width: 4),
                                              Text(r.time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: color.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        _statusLabel(r.status),
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
