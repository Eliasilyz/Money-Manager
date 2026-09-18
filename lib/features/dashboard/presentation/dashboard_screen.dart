import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          data: (data) {
            final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardProvider),
              color: AppColors.emerald,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildBalanceCard(context, data, fmt),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildSection(context, 'Recent Transactions', () => context.push('/transactions')),
                    if (data.recentTransactions.isEmpty)
                      _buildEmpty(context, 'No transactions yet')
                    else
                      ...data.recentTransactions.map((t) => _buildTransactionTile(context, t, fmt)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.coral))),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi 👋',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                'Money Manager',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.violet.withValues(alpha: 0.4), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person, color: AppColors.violet, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, DashboardData data, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emerald.withValues(alpha: 0.1),
                    AppColors.emerald.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SALDO',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Text(
                fmt.format(data.totalBalance),
                style: GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat(Icons.arrow_downward, 'Pemasukan', fmt.format(data.totalIncome), AppColors.emerald),
                  const SizedBox(width: 24),
                  _buildMiniStat(Icons.arrow_upward, 'Pengeluaran', fmt.format(data.totalExpenses), AppColors.coral),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _Action('Transaksi', Icons.receipt_long_outlined, () => context.push('/transactions'), AppColors.emerald),
      _Action('Transfer', Icons.swap_horiz_rounded, () => context.push('/transfers'), AppColors.violet),
      _Action('Anggaran', Icons.pie_chart_outline_rounded, () => context.push('/budgets'), AppColors.amber),
      _Action('Target', Icons.flag_outlined, () => context.push('/goals'), AppColors.blue),
      _Action('Hutang', Icons.money_off_rounded, () => context.push('/debts'), AppColors.coral),
      _Action('Berulang', Icons.repeat_rounded, () => context.push('/recurring'), AppColors.violet),
      _Action('Kategori', Icons.category_outlined, () => context.push('/categories'), AppColors.emerald),
      _Action('Mata Uang', Icons.monetization_on_outlined, () => context.push('/currencies'), AppColors.blue),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final a = actions[index];
          return GestureDetector(
            onTap: a.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: a.color.withValues(alpha: 0.15)),
                  ),
                  child: Icon(a.icon, color: a.color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  a.label,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text('See All', style: GoogleFonts.inter(fontSize: 12, color: AppColors.emerald)),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, dynamic t, NumberFormat fmt) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.emerald : AppColors.coral;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            t.description ?? t.note ?? t.type,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          subtitle: Text(
            DateFormat('d MMM yyyy').format(t.date),
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          trailing: Text(
            '$sign${fmt.format(t.amount)}',
            style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text(message, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _Action(this.label, this.icon, this.onTap, this.color);
}
