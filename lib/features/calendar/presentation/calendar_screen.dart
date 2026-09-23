import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();
  late NumberFormat _fmt;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    _fmt = NumberFormat.currency(symbol: '${currencySymbol(baseCode)} ', decimalDigits: currencyDigits(baseCode));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: transactionsAsync.when(
        data: (allTx) {
          final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? const <String, dynamic>{};

          final dayTx = allTx.where((t) =>
              t.date.year == _selectedDate.year &&
              t.date.month == _selectedDate.month &&
              t.date.day == _selectedDate.day).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          final dayIncome = dayTx.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + t.amount);
          final dayExpense = dayTx.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + t.amount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _buildMonthNav(colors, locale, l10n),
              const SizedBox(height: 12),
              _buildCalendarGrid(allTx, colors),
              const SizedBox(height: 20),
              _buildDaySummary(dayIncome, dayExpense, colors, locale, l10n),
              const SizedBox(height: 16),
              if (dayTx.isNotEmpty) ...[
                Text(l10n.transactions, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                const SizedBox(height: 10),
                ...dayTx.map((t) => _buildTxTile(t, catMap, colors, l10n)),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
                  child: Text(l10n.noTransactions, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary), textAlign: TextAlign.center),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _buildMonthNav(AppColorsT colors, String locale, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
          icon: Icon(Icons.chevron_left, color: colors.textPrimary),
          tooltip: l10n.monthYear,
        ),
        Text(
          DateFormat('MMMM yyyy', locale).format(_currentMonth),
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
                _selectedDate = DateTime.now();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Hari ini', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary)),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
              icon: Icon(Icons.chevron_right, color: colors.textPrimary),
              tooltip: l10n.monthYear,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(List<Transaction> allTx, AppColorsT colors) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final today = DateTime.now();

    final dayMap = <int, int>{};
    for (final t in allTx.where((t) => t.date.month == _currentMonth.month && t.date.year == _currentMonth.year)) {
      dayMap[t.date.day] = (dayMap[t.date.day] ?? 0) + (t.type == 'expense' ? -t.amount : t.amount);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: ['S', 'R', 'K', 'J', 'S', 'M', 'M'].map((d) => Expanded(
              child: Center(child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary))),
            )).toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(_weeksInMonth(firstDayWeekday, daysInMonth), (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayNum = cellIndex - firstDayWeekday + 2;
                if (dayNum < 1 || dayNum > daysInMonth) return const Expanded(child: SizedBox(height: 40));
                final day = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                final hasTx = dayMap.containsKey(dayNum);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : (isToday ? colors.primary.withValues(alpha: 0.1) : Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : colors.textPrimary,
                            ),
                          ),
                          if (hasTx && !isSelected)
                            Container(
                              width: 4, height: 4,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: (dayMap[dayNum] ?? 0) >= 0 ? AppColors.teal : AppColors.rose,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  int _weeksInMonth(int firstWeekday, int daysInMonth) {
    return ((daysInMonth + firstWeekday - 1) / 7).ceil();
  }

  Widget _buildDaySummary(int income, int expense, AppColorsT colors, String locale, AppLocalizations l10n) {
    final net = income - expense;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, d MMMM yyyy', locale).format(_selectedDate), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              _dayStat(Icons.arrow_downward_rounded, l10n.income, income, AppColors.teal),
              const SizedBox(width: 16),
              _dayStat(Icons.arrow_upward_rounded, l10n.expense, expense, AppColors.rose),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
              Text(
                '${net >= 0 ? '+' : '-'}${_fmt.format(net.abs())}',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: net >= 0 ? AppColors.teal : AppColors.rose),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayStat(IconData icon, String label, int value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              Text(_fmt.format(value), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(Transaction t, Map catMap, AppColorsT colors, AppLocalizations l10n) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';
    final cat = catMap[t.categoryId];
    final catName = cat == null ? l10n.other : localizedCategoryName(l10n, cat.systemKey, cat.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.teal : AppColors.rose).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (t.description != null && t.description!.isNotEmpty) ? t.description! : catName,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
                ),
                Text(
                  '$catName • ${DateFormat('HH:mm').format(t.date)}',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text('$sign${_fmt.format(t.amount)}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
