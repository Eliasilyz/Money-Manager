import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              'Lainnya',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            _buildSection('Pengelolaan'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Akun',
              subtitle: 'Kelola rekening dan dompet',
              color: AppColors.emerald,
              onTap: () => context.push('/accounts'),
            ),
            _SettingsTile(
              icon: Icons.category_outlined,
              label: 'Kategori',
              subtitle: 'Kelola kategori pemasukan & pengeluaran',
              color: AppColors.blue,
              onTap: () => context.push('/categories'),
            ),
            _SettingsTile(
              icon: Icons.pie_chart_outline,
              label: 'Anggaran',
              subtitle: 'Atur batas pengeluaran',
              color: AppColors.amber,
              onTap: () => context.push('/budgets'),
            ),
            _SettingsTile(
              icon: Icons.flag_outlined,
              label: 'Target Tabungan',
              subtitle: 'Pantau pencapaian目標',
              color: AppColors.violet,
              onTap: () => context.push('/goals'),
            ),
            _SettingsTile(
              icon: Icons.money_off_rounded,
              label: 'Hutang & Piutang',
              subtitle: 'Kelola hutang dan piutang',
              color: AppColors.coral,
              onTap: () => context.push('/debts'),
            ),
            _SettingsTile(
              icon: Icons.repeat_rounded,
              label: 'Transaksi Berulang',
              subtitle: 'Atur pemasukan & pengeluaran rutin',
              color: AppColors.violet,
              onTap: () => context.push('/recurring'),
            ),
            _SettingsTile(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              subtitle: 'Transfer antar akun',
              color: AppColors.blue,
              onTap: () => context.push('/transfers'),
            ),
            _SettingsTile(
              icon: Icons.monetization_on_outlined,
              label: 'Mata Uang',
              subtitle: 'Lihat mata uang yang tersedia',
              color: AppColors.emerald,
              onTap: () => context.push('/currencies'),
            ),
            const SizedBox(height: 24),
            _buildSection('Tentang'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.emerald, AppColors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Money Manager',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Personal Finance Tracker',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aplikasi pencatatan keuangan pribadi yang sederhana dan powerful. '
                    'Pantau pemasukan, pengeluaran, transfer, anggaran, target tabungan, '
                    'dan hutang dalam satu tempat.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  _infoRow('Versi', '1.0.0 (Build 1)'),
                  const SizedBox(height: 8),
                  _infoRow('Dibuat dengan', 'Flutter · Drift · Riverpod'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
        ),
      ),
    );
  }
}
