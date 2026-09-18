import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/transaction.dart';
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
              color: AppColors.gold,
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
                    _buildSection(context, 'Transaksi Terakhir', () => context.push('/transactions')),
                    if (data.recentTransactions.isEmpty)
                      _buildEmpty(context, 'Belum ada transaksi')
                    else
                      ...data.recentTransactions.map((t) => _buildTransactionTile(context, t, fmt)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.lilac, AppColors.sky],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 20),
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
                    AppColors.gold.withValues(alpha: 0.08),
                    AppColors.gold.withValues(alpha: 0.0),
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
                style: GoogleFonts.jetBrainsMono(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(Icons.arrow_downward, 'Pemasukan', fmt.format(data.totalIncome), AppColors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStat(Icons.arrow_upward, 'Pengeluaran', fmt.format(data.totalExpenses), AppColors.rose),
                  ),
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
      mainAxisSize: MainAxisSize.min,
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
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
              Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _Action('Transaksi', Icons.receipt_long_outlined, () => context.push('/transactions'), AppColors.teal),
      _Action('Transfer', Icons.swap_horiz_rounded, () => context.push('/transfers'), AppColors.sky),
      _Action('Anggaran', Icons.pie_chart_outline_rounded, () => context.push('/budgets'), AppColors.orange),
      _Action('Target', Icons.flag_outlined, () => context.push('/goals'), AppColors.lilac),
      _Action('Hutang', Icons.money_off_rounded, () => context.push('/debts'), AppColors.rose),
      _Action('Berulang', Icons.repeat_rounded, () => context.push('/recurring'), AppColors.sky),
      _Action('Kategori', Icons.category_outlined, () => context.push('/categories'), AppColors.teal),
      _Action('Mata Uang', Icons.monetization_on_outlined, () => context.push('/currencies'), AppColors.gold),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
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
              child: Text('Lihat Semua', style: GoogleFonts.inter(fontSize: 12, color: AppColors.gold)),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction t, NumberFormat fmt) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
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
            const Text('📭', style: TextStyle(fontSize: 48)),
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
