import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/i_reservation_repository.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final repository = sl<IReservationRepository>();
  int totalReservations = 0;
  int confirmedReservations = 0;
  int pendingReservations = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    try {
      final reservations = await repository.getUserReservations(widget.userId);
      if (mounted) {
        setState(() {
          totalReservations = reservations.length;
          confirmedReservations = reservations.where((r) => r.status == "CONFIRMED").length;
          pendingReservations = reservations.where((r) => r.status == "PENDING").length;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
                  const Text(
                    "Meu Perfil",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.accentColor),
                    onPressed: _loadStats,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      child: const Icon(Icons.person, size: 48, color: AppTheme.accentColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userEmail,
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Stats Row
              isLoading
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard(totalReservations.toString(), "Reservas\nFeitas"),
                        _statCard(confirmedReservations.toString(), "Confirmadas"),
                        _statCard(pendingReservations.toString(), "Pendentes"),
                      ],
                    ),
              const SizedBox(height: 32),
              // Menu Options
              _menuItem(Icons.edit, "Editar Dados", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edição de perfil será implementada na próxima versão.')),
                );
              }),
              _menuItem(Icons.lock_outline, "Alterar Senha", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alteração de senha será implementada na próxima versão.')),
                );
              }),
              _menuItem(Icons.notifications_outlined, "Notificações", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificações serão implementadas na próxima versão.')),
                );
              }),
              _menuItem(Icons.help_outline, "Ajuda", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Central de ajuda online disponível em breve.')),
                );
              }),
              const Spacer(),
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text("Sair", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.accentColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      onTap: onTap,
    );
  }
}
