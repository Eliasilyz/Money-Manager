import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final goalsAsync = ref.watch(goalsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goalsAndDebtsTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/add-goal'),
            icon: Icon(Icons.add, color: colors.primary, size: 18),
            label: Text('Tambah', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
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
                    _tabPill(context, l10n.savingsTarget, true),
                    _tabPill(context, l10n.debts, false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (goals.isNotEmpty) ...[
                // Priority card
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
                          const Spacer(),
                          Icon(Icons.star_outline, color: Colors.white.withValues(alpha: 0.7), size: 18),
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
                // Secondary goal cards
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
                              Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.lilac.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.savings_outlined, color: AppColors.lilac, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(g.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(fmt.format(g.currentAmount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (g.currentAmount / g.targetAmount).clamp(0.0, 1.0),
                                  backgroundColor: colors.border,
                                  color: colors.primary,
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('$pct% tercapai', style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ] else ...[
                _buildEmpty(context, l10n),
              ],
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ringkasan hutang', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.push('/debts'),
                    child: Text('Lihat semua', style: GoogleFonts.inter(fontSize: 12, color: colors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Debt total card
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
                    Text('Total sisa hutang', style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      'Rp 22.750.000',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.rose),
                    ),
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

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
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
            Text(l10n.noData, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
