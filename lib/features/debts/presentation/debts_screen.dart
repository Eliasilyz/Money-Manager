import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final debtsAsync = ref.watch(debtsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hutang & Piutang', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: debtsAsync.when(
        data: (debts) {
          if (debts.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: debts.map((d) {
              final isBorrowed = d.type == 'borrowed';
              final isPaid = d.status == 'paid';
              final isOverdue = !isPaid && d.dueDate.isBefore(DateTime.now());
              final color = isPaid ? colors.textSecondary : (isOverdue ? colors.expense : (isBorrowed ? colors.expense : colors.income));
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            d.personName,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          isBorrowed ? 'Hutang' : 'Piutang',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(d.remainingAmount),
                      style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(d.dueDate)}',
                      style: GoogleFonts.inter(fontSize: 11, color: isOverdue ? colors.expense : colors.textSecondary),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'debts_fab',
        onPressed: () => context.push('/add-debt'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
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
            child: const Icon(Icons.money_off_rounded, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text('Belum ada hutang atau piutang', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}