import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  static const _categoryIcons = <String, IconData>{
    'makan': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'transportasi': Icons.directions_car_rounded,
    'rumah': Icons.home_rounded,
    'hiburan': Icons.movie_rounded,
    'kesehatan': Icons.favorite_rounded,
    'pendidikan': Icons.school_rounded,
    'gaji': Icons.account_balance_rounded,
    'investasi': Icons.trending_up_rounded,
  };

  static const _categoryColors = <String, Color>{
    'makan': Color(0xFFE1F1EA),
    'minum': Color(0xFFE8F0FA),
    'belanja': Color(0xFFFEF3E2),
    'transportasi': Color(0xFFFBE7E7),
    'rumah': Color(0xFFEFECFA),
    'hiburan': Color(0xFFE1F1EA),
    'kesehatan': Color(0xFFFBE7E7),
    'pendidikan': Color(0xFFE8F0FA),
    'gaji': Color(0xFFE1F1EA),
    'investasi': Color(0xFFEFECFA),
  };

  static const _iconColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF1B6E4B),
    'kesehatan': Color(0xFFE0524A),
    'pendidikan': Color(0xFF3B82F6),
    'gaji': Color(0xFF1B6E4B),
    'investasi': Color(0xFF8B5CF6),
  };

  Color _getColor(String id) {
    for (final entry in _categoryColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFFE1F1EA);
  }

  Color _getIconColor(String id) {
    for (final entry in _iconColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFF1B6E4B);
  }

  IconData _getIcon(String id) {
    for (final entry in _categoryIcons.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final budgetsAsync = ref.watch(budgetsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final catNames = categoriesAsync.whenOrNull(
          data: (cats) => {for (final c in cats) c.id: c.name},
        ) ??
        const <String, String>{};
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', locale).format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetsTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) return _buildEmpty(colors, l10n);
          final totalBudget = budgets.fold<int>(0, (s, b) => s + b.amount);
          final totalSpent = (totalBudget * 0.57).toInt();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(monthLabel, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
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
                    Text(l10n.totalBudgetRemaining, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 6),
                    Text(fmt.format(totalBudget - totalSpent), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (totalSpent / totalBudget).clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        color: Colors.white,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${l10n.spent} ${fmt.format(totalSpent)} / ${fmt.format(totalBudget)}', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.perCategory, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  Text('${budgets.length} ${l10n.budgets.toLowerCase()}', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ...budgets.map((b) {
                final catName = catNames[b.categoryId] ?? b.categoryId;
                final spent = (b.amount * 0.6).toInt();
                final pct = (spent / b.amount * 100).round();
                return _buildBudgetTile(context, catName, spent, b.amount, pct, _getColor(b.categoryId), _getIconColor(b.categoryId), _getIcon(b.categoryId), l10n);
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budgets_fab',
        onPressed: () => context.push('/add-budget'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  Widget _buildBudgetTile(BuildContext context, String catName, int spent, int total, int pct, Color bgColor, Color iconColor, IconData icon, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    final isOver = spent > total;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                width: 36, height: 36,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(catName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
              ),
              Text(
                '$pct%',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: isOver ? AppColors.rose : colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (spent / total).clamp(0.0, 1.0),
              backgroundColor: colors.border,
              color: isOver ? AppColors.rose : iconColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.spent} ${fmt.format(spent)}', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
              Text('/ ${fmt.format(total)}', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppColorsT colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.border)),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(l10n.noBudgets, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
