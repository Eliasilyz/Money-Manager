import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
      ),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: items.map((rt) {
              final label = '${_frequencyLabel(rt.frequency)} · setiap ${rt.interval}x';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.repeat_rounded, color: colors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Berikutnya: ${DateFormat('dd MMM yyyy').format(rt.nextOccurrence)}',
                            style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: rt.enabled,
                      onChanged: (_) => ref.read(recurringTransactionsNotifierProvider.notifier).toggle(rt),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: const Icon(Icons.repeat_rounded, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text('Belum ada transaksi berulang', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}