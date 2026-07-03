import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/i_reservation_repository.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/court.dart';
import '../../core/theme/app_theme.dart';

class AgendaScreen extends StatefulWidget {
  final String userId;

  const AgendaScreen({super.key, required this.userId});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final repository = sl<IReservationRepository>();
  List<CourtEntity> courts = [];
  List<TimeSlot> slots = [];
  bool isLoading = true;
  bool isLoadingCourts = true;
  bool hasErrorCourts = false;
  bool hasErrorSlots = false;

  String? selectedCourtId;
  DateTime weekStart = DateTime(2026, 7, 3); // Sexta 3 jul

  final times = [
    "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00",
    "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"
  ];

  List<Map<String, String>> get weekDays {
    final abbr = ["SEX", "SÁB", "DOM", "SEG", "TER", "QUA", "QUI"];
    final keys = ["sex", "sab", "dom", "seg", "ter", "qua", "qui"];
    return List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return {
        "label": "${abbr[i]}. ${d.day}",
        "key": keys[i],
        "dateStr": "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}",
      };
    });
  }

  String get selectedCourtName {
    if (selectedCourtId == null || courts.isEmpty) return "";
    try {
      return courts.firstWhere((c) => c.id == selectedCourtId).name;
    } catch (_) {
      return "";
    }
  }

  String get weekLabel {
    final end = weekStart.add(const Duration(days: 6));
    final months = [
      "", "janeiro", "fevereiro", "março", "abril", "maio", "junho",
      "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"
    ];
    if (weekStart.month == end.month) {
      return "Semana de ${weekStart.day} a ${end.day} de ${months[weekStart.month]}";
    }
    return "Semana de ${weekStart.day}/${weekStart.month} a ${end.day}/${end.month}";
  }

  String get monthYear {
    final months = [
      "", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
      "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ];
    return "${months[weekStart.month]} ${weekStart.year}";
  }

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  // Carrega a lista de quadras do servidor
  Future<void> _loadCourts() async {
    setState(() {
      isLoadingCourts = true;
      hasErrorCourts = false;
    });
    try {
      final data = await repository.getCourts();
      setState(() {
        courts = data;
        if (data.isNotEmpty) {
          selectedCourtId = data.first.id;
        } else {
          selectedCourtId = null;
        }
        isLoadingCourts = false;
      });
      if (selectedCourtId != null) {
        _loadSlots();
      }
    } catch (e) {
      setState(() {
        isLoadingCourts = false;
        hasErrorCourts = true;
      });
    }
  }

  // Carrega os horários disponíveis (slots) para a quadra selecionada na semana
  Future<void> _loadSlots() async {
    if (selectedCourtId == null) return;
    setState(() {
      isLoading = true;
      hasErrorSlots = false;
    });
    try {
      final data = await repository.getAvailableSlots(selectedCourtId!, weekStart);
      setState(() {
        slots = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasErrorSlots = true;
      });
    }
  }

  void _previousWeek() {
    setState(() => weekStart = weekStart.subtract(const Duration(days: 7)));
    _loadSlots();
  }

  void _nextWeek() {
    setState(() => weekStart = weekStart.add(const Duration(days: 7)));
    _loadSlots();
  }

  TimeSlot? _getSlot(String dayKey, String time) {
    try {
      return slots.firstWhere((s) => s.dayKey == dayKey && s.time == time);
    } catch (_) {
      return null;
    }
  }

  // Exibe o modal de confirmação de reserva
  void _showReservationDialog(TimeSlot slot, Map<String, String> dayData) {
    final allEndTimes = [
      "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", 
      "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30"
    ];

    int parseTimeToMinutes(String timeStr) {
      final parts = timeStr.split(":");
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final startMinutes = parseTimeToMinutes(slot.time);

    // Encontra o próximo horário indisponível para limitar o término da reserva e evitar sobreposição
    String? firstUnavailableTime;
    for (var t in times) {
      if (parseTimeToMinutes(t) > startMinutes) {
        final checkSlot = _getSlot(dayData["key"]!, t);
        if (checkSlot != null && !checkSlot.isAvailable) {
          firstUnavailableTime = t;
          break;
        }
      }
    }

    final selectableEndTimes = allEndTimes.where((t) {
      final m = parseTimeToMinutes(t);
      if (m <= startMinutes) return false;
      if (firstUnavailableTime != null && m > parseTimeToMinutes(firstUnavailableTime)) return false;
      return true;
    }).toList();

    String selectedEndTime = selectableEndTimes.isNotEmpty ? selectableEndTimes.first : "21:30";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.event_available, color: AppTheme.accentColor, size: 22),
              const SizedBox(width: 8),
              const Text('Confirmar Reserva', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogRow(Icons.sports, "Quadra", selectedCourtName),
              const SizedBox(height: 8),
              _dialogRow(Icons.calendar_today, "Dia", dayData["label"]!),
              const SizedBox(height: 8),
              _dialogRow(Icons.access_time, "Início", slot.time),
              const SizedBox(height: 16),
              const Text("Horário de Término:", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedEndTime,
                    dropdownColor: AppTheme.cardColor,
                    style: const TextStyle(color: Colors.white),
                    items: selectableEndTimes.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedEndTime = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Confirmar'),
              onPressed: () async {
                Navigator.pop(context);
                
                setState(() => isLoading = true);
                final endMinutes = parseTimeToMinutes(selectedEndTime);
                final durationMinutes = endMinutes - startMinutes;

                try {
                  // Cria reserva utilizando o repositório
                  final success = await repository.createReservation(
                    widget.userId,
                    selectedCourtId!,
                    dayData["dateStr"]!,
                    slot.time,
                    durationMinutes,
                  );
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reserva efetuada em $selectedCourtName das ${slot.time} até $selectedEndTime!'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                    _loadSlots();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao efetuar reserva. O horário pode estar ocupado.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    setState(() => isLoading = false);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro de conexão: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  setState(() => isLoading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.accentColor),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double dayColWidth = screenWidth > 1000
        ? (screenWidth - 120) / 7
        : 140.0;

    final days = weekDays;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              const Text(
                "Selecione uma quadra",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Court Chips - Dynamic from Database
              hasErrorCourts
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.cloud_off, color: Colors.redAccent, size: 20),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Servidor indisponível ou offline.",
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _loadCourts,
                            icon: const Icon(Icons.refresh, size: 16, color: AppTheme.accentColor),
                            label: const Text("Tentar", style: TextStyle(color: AppTheme.accentColor, fontSize: 13)),
                          )
                        ],
                      ),
                    )
                  : isLoadingCourts
                      ? const SizedBox(
                          height: 40,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor)),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: courts.map((court) {
                              final isSelected = court.id == selectedCourtId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _buildCourtChip(court.id, court.name, isSelected),
                              );
                            }).toList(),
                          ),
                        ),
              const SizedBox(height: 20),

              // Week Navigator Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Text(
                          monthYear,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 24),
                        _weekNavButton(Icons.chevron_left, _previousWeek),
                        const SizedBox(width: 4),
                        Text(
                          weekLabel,
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(width: 4),
                        _weekNavButton(Icons.chevron_right, _nextWeek),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Table
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : hasErrorSlots
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
                                const SizedBox(height: 12),
                                const Text(
                                  "Não foi possível carregar os horários.",
                                  style: TextStyle(color: Colors.white60, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadSlots,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Tentar novamente"),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time column
                              Column(
                                children: [
                                  Container(height: 50, width: 65),
                                  ...times.map((t) => Container(
                                        height: 76,
                                        width: 65,
                                        alignment: Alignment.topRight,
                                        padding: const EdgeInsets.only(right: 10, top: 6),
                                        child: Text(
                                          t,
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                              // Day columns
                              ...days.map((day) {
                                return SizedBox(
                                  width: dayColWidth,
                                  child: Column(
                                    children: [
                                      // Day header cell
                                      Container(
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.headerColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          day["label"]!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      // Slot cells
                                      ...times.map((time) {
                                        final slot = _getSlot(day["key"]!, time);
                                        return _buildCell(slot, day);
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildCourtChip(String id, String name, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedCourtId = id);
        _loadSlots();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.25) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sports,
              size: 15,
              color: isSelected ? AppTheme.accentColor : Colors.white54,
            ),
            const SizedBox(width: 7),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCell(TimeSlot? slot, Map<String, String> dayData) {
    final height = 76.0;
    if (slot == null) {
      return Container(height: height, margin: const EdgeInsets.all(2));
    }

    final bgColor = slot.isAvailable
        ? AppTheme.primaryColor.withValues(alpha: 0.6)
        : AppTheme.unavailableColor.withValues(alpha: 0.18);
    final borderColor = slot.isAvailable
        ? AppTheme.accentColor.withValues(alpha: 0.45)
        : Colors.transparent;
    final textColor = slot.isAvailable ? AppTheme.accentColor : Colors.white24;
    final timeColor = slot.isAvailable ? Colors.white70 : Colors.white24;

    return GestureDetector(
      onTap: slot.isAvailable ? () => _showReservationDialog(slot, dayData) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              slot.isAvailable ? "Horário livre" : "Indisponível",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            Row(
              children: [
                Icon(Icons.access_time, size: 10, color: timeColor),
                const SizedBox(width: 4),
                Text(
                  slot.time,
                  style: TextStyle(color: timeColor, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
