import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  String _frequencyLabel(String f) {
    return switch (f) {
      'daily' => 'Harian',
      'weekly' => 'Mingguan',
      'monthly' => 'Bulanan',
      'yearly' => 'Tahunan',
      _ => f,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final asyncItems = ref.watch(recurringTransactionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi Berulang', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: Text('Tambah', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) return _buildEmpty(context);
          final active = items.where((rt) => rt.enabled).length;
          final inactive = items.length - active;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('Otomatis dan terjadwal', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primaryDark, colors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: colors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Proyeksi bulan depan', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 6),
                    Text(
                      '${items.length} transaksi berulang',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statBadge('$active aktif', Colors.white.withValues(alpha: 0.2)),
                        if (inactive > 0) ...[
                          const SizedBox(width: 8),
                          _statBadge('$inactive nonaktif', Colors.white.withValues(alpha: 0.2)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Akan datang', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  Text('${items.length} item', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map((rt) {
                final daysUntil = rt.nextOccurrence.difference(DateTime.now()).inDays;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: (rt.enabled ? AppColors.gold : colors.textSecondary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.repeat_rounded, color: rt.enabled ? AppColors.gold : colors.textSecondary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_frequencyLabel(rt.frequency)} · setiap ${rt.interval}x',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Berikutnya: ${rt.nextOccurrence.day} ${_monthName(rt.nextOccurrence.month)} · ${daysUntil > 0 ? '$daysUntil hari lagi' : 'hari ini'}',
                              style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: rt.enabled,
                        onChanged: (_) => ref.read(recurringTransactionsNotifierProvider.notifier).toggle(rt),
                        activeTrackColor: AppColors.gold,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Langganan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  Text('Kelola', style: GoogleFonts.inter(fontSize: 12, color: colors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _subscriptionCard('Netflix', Icons.movie_rounded, const Color(0xFFE50914), 'Rp 186 rb/bulan', colors),
                  const SizedBox(width: 10),
                  _subscriptionCard('Spotify', Icons.music_note_rounded, const Color(0xFF1DB954), 'Rp 55 rb/bulan', colors),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  String _monthName(int m) {
    const months = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    return months[m - 1];
  }

  Widget _statBadge(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white)),
    );
  }

  Widget _subscriptionCard(String name, IconData icon, Color brandColor, String price, AppColorsT colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: brandColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  Text(price, style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.border)),
            child: const Icon(Icons.repeat_rounded, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text('Belum ada transaksi berulang', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}