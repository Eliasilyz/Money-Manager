import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final baseCode = ref.watch(baseCurrencyCodeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.calendar,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(_currentMonth),
              style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => setState(() {
                _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
                _selectedDate = DateTime.now();
              }),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.today,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (allTx) {
          final catMap = categoriesAsync.whenOrNull(
                data: (cats) => {for (final c in cats) c.id: c},
              ) ??
              const <String, dynamic>{};

          final dayTx = allTx
              .where((t) =>
                  t.date.year == _selectedDate.year &&
                  t.date.month == _selectedDate.month &&
                  t.date.day == _selectedDate.day)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          final dayIncome = dayTx
              .where((t) => t.type == 'income')
              .fold<int>(0, (s, t) => s + t.amount);
          final dayExpense = dayTx
              .where((t) => t.type == 'expense')
              .fold<int>(0, (s, t) => s + t.amount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _buildMonthNav(colors),
              const SizedBox(height: 16),
              _buildCalendarGrid(allTx, colors),
              const SizedBox(height: 20),
              _buildDaySummary(dayIncome, dayExpense, colors, baseCode),
              const SizedBox(height: 16),
              if (dayTx.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.transactionDetails,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.transactionCount(dayTx.length),
                      style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...dayTx.map((t) => _buildTxTile(t, catMap, colors, l10n, baseCode)),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_rounded, size: 36, color: colors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 10),
                      Text(
                        l10n.noTransactions,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _buildMonthNav(AppColorsT colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => setState(() =>
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.chevron_left_rounded, color: colors.textPrimary, size: 20),
          ),
        ),
        Column(
          children: [
            Text(
              DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(_currentMonth),
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () => setState(() =>
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.chevron_right_rounded, color: colors.textPrimary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(List<Transaction> allTx, AppColorsT colors) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // firstDayWeekday: 1=Mon, adjusting to start on Monday (index 0)
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final today = DateTime.now();

    // Build expense/income per day
    final dayExpense = <int, int>{};
    final dayIncome = <int, int>{};
    for (final t in allTx.where((t) =>
        t.date.month == _currentMonth.month && t.date.year == _currentMonth.year)) {
      if (t.type == 'expense') {
        dayExpense[t.date.day] = (dayExpense[t.date.day] ?? 0) + t.amount;
      } else if (t.type == 'income') {
        dayIncome[t.date.day] = (dayIncome[t.date.day] ?? 0) + t.amount;
      }
    }

    final locale = Localizations.localeOf(context).languageCode;
    final dayHeaders = List.generate(7, (i) {
      final sample = DateTime(2026, 1, 5 + i); // 2026-01-05 is a Monday
      return DateFormat('E', locale).format(sample);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day headers
          Row(
            children: dayHeaders
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(_weeksInMonth(firstDayWeekday, daysInMonth), (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                // firstDayWeekday: 1=Mon ... 7=Sun
                final offset = firstDayWeekday - 1; // days to skip at start
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayNum = cellIndex - offset + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }

                final day = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final isToday = day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;
                final isSelected = day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                final hasExp = dayExpense.containsKey(dayNum);
                final hasInc = dayIncome.containsKey(dayNum);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : (isToday
                                ? colors.primary.withValues(alpha: 0.1)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
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
                          if ((hasExp || hasInc) && !isSelected) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasExp)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (hasInc)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2A9D8F),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
    final offset = firstWeekday - 1;
    return ((daysInMonth + offset) / 7).ceil();
  }

  Widget _buildDaySummary(int income, int expense, AppColorsT colors, String baseCode) {
    final l10n = AppLocalizations.of(context);
    final net = income - expense;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy', Localizations.localeOf(context).languageCode).format(_selectedDate),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _daySummaryTile(
                  icon: Icons.arrow_downward_rounded,
                  iconBg: const Color(0xFFE8F5F3),
                  iconColor: const Color(0xFF2A9D8F),
                  label: l10n.income,
                  value: formatCurrency(income, currencyCode: baseCode),
                  valueColor: const Color(0xFF2A9D8F),
                  colors: colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _daySummaryTile(
                  icon: Icons.arrow_upward_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                  label: l10n.expense,
                  value: formatCurrency(expense, currencyCode: baseCode),
                  valueColor: const Color(0xFFEF4444),
                  colors: colors,
                ),
              ),
            ],
          ),
          if (income > 0 || expense > 0) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.todayBalance,
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                ),
                Text(
                  '${net >= 0 ? '+' : ''}${formatCurrency(net, currencyCode: baseCode)}',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: net >= 0 ? const Color(0xFF2A9D8F) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _daySummaryTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required AppColorsT colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary, fontWeight: FontWeight.w600)),
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(Transaction t, Map catMap, AppColorsT colors, AppLocalizations l10n, String baseCode) {
    final isIncome = t.type == 'income';
    final txColor = isIncome ? const Color(0xFF2A9D8F) : const Color(0xFFEF4444);
    final iconBg = isIncome ? const Color(0xFFE8F5F3) : const Color(0xFFFEE2E2);
    final sign = isIncome ? '+' : '-';
    final cat = catMap[t.categoryId];
    final catName = cat == null ? l10n.categoryDefaultOtherIncome : localizedCategoryName(l10n, cat.systemKey, cat.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: txColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (t.description != null && t.description!.isNotEmpty) ? t.description! : catName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$catName • ${DateFormat('HH:mm').format(t.date)}',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${formatCurrency(t.amount, currencyCode: baseCode)}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: txColor,
            ),
          ),
        ],
      ),
    );
  }
}
