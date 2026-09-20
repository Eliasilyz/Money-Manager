import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final goalsAsync = ref.watch(goalsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Target & Hutang', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/add-goal'),
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
      body: goalsAsync.when(
        data: (goals) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    _tabPill(context, 'Target tabungan', true),
                    _tabPill(context, 'Hutang', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (goals.isNotEmpty) ...[
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('PRIORITAS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(goals.first.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(fmt.format(goals.first.targetAmount), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        '${(goals.first.currentAmount / goals.first.targetAmount * 100).toStringAsFixed(0)}% dari ${fmt.format(goals.first.targetAmount)}',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      if (goals.first.targetDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM yyyy').format(goals.first.targetDate!),
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ],
                  ),
                ),
                if (goals.length > 1) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: goals.skip(1).take(2).map((g) {
                      final pct = g.targetAmount > 0 ? (g.currentAmount / g.targetAmount * 100).toStringAsFixed(0) : '0';
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textSecondary)),
                              const SizedBox(height: 6),
                              Text(fmt.format(g.currentAmount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('$pct% tercapai', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ] else ...[
                _buildEmpty(context),
              ],
              const SizedBox(height: 28),
              Text('Ringkasan hutang', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.money_off_rounded, size: 32, color: colors.textSecondary),
                    const SizedBox(height: 8),
                    Text('Belum ada hutang', style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _tabPill(BuildContext context, String label, bool selected) {
    final colors = AppColorsT.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.border)),
              child: const Icon(Icons.flag_outlined, size: 32, color: AppColors.gold),
            ),
            const SizedBox(height: 16),
            Text('Belum ada target keuangan', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}