import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

String formatCurrency(num amount, {String currencyCode = 'IDR', String locale = 'id'}) {
  final digits = currencyDigits(currencyCode);
  final symbol = currencySymbol(currencyCode);
  final fmt = NumberFormat.currency(
    locale: locale,
    symbol: symbol.isNotEmpty ? '$symbol ' : '',
    decimalDigits: digits,
  );
  return fmt.format(amount);
}

String localizedCategoryName(AppLocalizations l10n, String? systemKey, String fallback) {
  switch (systemKey) {
    case 'food_drink':
      return l10n.categoryDefaultFoodDrink;
    case 'transport':
      return l10n.categoryDefaultTransport;
    case 'shopping':
      return l10n.categoryDefaultShopping;
    case 'housing':
      return l10n.categoryDefaultHousing;
    case 'utilities':
      return l10n.categoryDefaultUtilities;
    case 'health':
      return l10n.categoryDefaultHealth;
    case 'education':
      return l10n.categoryDefaultEducation;
    case 'entertainment':
      return l10n.categoryDefaultEntertainment;
    case 'vacation':
      return l10n.categoryDefaultVacation;
    case 'family':
      return l10n.categoryDefaultFamily;
    case 'personal_care':
      return l10n.categoryDefaultPersonalCare;
    case 'gifts':
      return l10n.categoryDefaultGifts;
    case 'debt_payment':
      return l10n.categoryDefaultDebtPayment;
    case 'insurance':
      return l10n.categoryDefaultInsurance;
    case 'subscriptions':
      return l10n.categoryDefaultSubscriptions;
    case 'other_expense':
      return l10n.categoryDefaultOtherExpense;
    case 'salary':
      return l10n.categoryDefaultSalary;
    case 'bonus':
      return l10n.categoryDefaultBonus;
    case 'business':
      return l10n.categoryDefaultBusiness;
    case 'investment':
      return l10n.categoryDefaultInvestment;
    case 'gift':
      return l10n.categoryDefaultGift;
    case 'sale':
      return l10n.categoryDefaultSale;
    case 'refund':
      return l10n.categoryDefaultRefund;
    case 'other_income':
      return l10n.categoryDefaultOtherIncome;
    case 'balance_adjustment':
      return l10n.categoryDefaultBalanceAdjustment;
    case 'transfer':
      return l10n.categoryDefaultTransfer;
    default:
      return fallback;
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool centerTitle;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class MonthPill extends StatelessWidget {
  final DateTime month;
  final VoidCallback? onTap;

  const MonthPill({super.key, required this.month, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final label = DateFormat('MMM yyyy', locale).format(month);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? border;
  final List<Color>? gradientColors;

  const HeroCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.heroCard,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: border != null ? Border.all(color: border!.color, width: border!.width) : null,
        image: gradientColors != null
            ? null
            : null,
      ),
      child: child,
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const StatCard({super.key, required this.label, required this.value, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary))),
      ]),
    );
  }
}

class TintedInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color tintColor;
  final EdgeInsetsGeometry? padding;

  const TintedInfoCard({super.key, required this.title, required this.value, required this.tintColor, this.padding});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tintColor.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
      ]),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String? title;
  final String? description;
  final String amount;
  final bool isIncome;
  final DateTime? date;
  final String? categoryName;
  final String? accountName;
  final String? categoryIcon;
  final VoidCallback? onTap;
  final Color? categoryColor;
  final bool isTransfer;
  final String? fromAccountName;
  final String? toAccountName;
  final String? note;

  const TransactionTile({
    super.key,
    this.title,
    this.description,
    required this.amount,
    required this.isIncome,
    this.date,
    this.categoryName,
    this.accountName,
    this.categoryIcon,
    this.onTap,
    this.categoryColor,
    this.isTransfer = false,
    this.fromAccountName,
    this.toAccountName,
    this.note,
  });

  String _resolvedTitle({String? incomeLabel, String? expenseLabel, String? transferLabel}) {
    if (title != null && title!.isNotEmpty) return title!;
    if (isTransfer) {
      final from = fromAccountName ?? '?';
      final to = toAccountName ?? '?';
      return '${transferLabel ?? 'Transfer'}: $from → $to';
    }
    if (note != null && note!.isNotEmpty) return note!;
    if (categoryName != null && categoryName!.isNotEmpty) return categoryName!;
    return isIncome ? (incomeLabel ?? 'Income') : (expenseLabel ?? 'Expense');
  }

  String _resolvedSubtitle(String locale, {String? todayLabel, String? yesterdayLabel}) {
    final parts = <String>[];
    if (isTransfer) {
      final from = fromAccountName ?? '?';
      final to = toAccountName ?? '?';
      parts.add('$from → $to');
    } else {
      if (categoryName != null && categoryName!.isNotEmpty) parts.add(categoryName!);
      if (accountName != null && accountName!.isNotEmpty) parts.add(accountName!);
    }
    parts.add(_formatDate(date, locale: locale, todayLabel: todayLabel, yesterdayLabel: yesterdayLabel));
    return parts.where((p) => p.isNotEmpty).join(' • ');
  }

  static String _formatDate(DateTime? d, {String locale = 'id', String? todayLabel, String? yesterdayLabel}) {
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(d.year, d.month, d.day);
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    if (txDay == today) return '${todayLabel ?? 'Today'} • $timeStr';
    if (txDay == today.subtract(const Duration(days: 1))) return '${yesterdayLabel ?? 'Yesterday'} • $timeStr';
    final monthStr = DateFormat('MMM', locale).format(d);
    return '${d.day} $monthStr ${d.year.toString().substring(2)} • $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final color = isIncome ? colors.income : colors.expense;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: (categoryColor ?? color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isTransfer
                ? Icons.swap_horiz_rounded
                : (isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
            color: categoryColor ?? color,
            size: 18,
          ),
        ),
        title: Text(
          _resolvedTitle(incomeLabel: l10n.income, expenseLabel: l10n.expense, transferLabel: l10n.transfer),
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _resolvedSubtitle(locale, todayLabel: l10n.todayTitle, yesterdayLabel: l10n.yesterdayTitle),
          style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(amount, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const PillChip({super.key, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : colors.textPrimary)),
      ),
    );
  }
}

class LabelledProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final String progressText;
  final Color color;

  const LabelledProgressBar({super.key, required this.label, required this.progress, required this.progressText, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
        Text(progressText, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary)),
      ]),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: colors.border, color: color, minHeight: 5, borderRadius: BorderRadius.circular(4)),
    ]);
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({super.key, required this.message, this.icon, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon ?? Icons.info_outline, size: 48, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!, style: GoogleFonts.inter(color: colors.primary, fontWeight: FontWeight.w600))),
          ],
        ]),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white);
          }
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.45));
        }),
      ),
      child: NavigationBar(
        backgroundColor: colors.navBackground,
        indicatorColor: Colors.transparent,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white.withValues(alpha: 0.45), size: 24),
            selectedIcon: const Icon(Icons.home_rounded, color: Colors.white, size: 24),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: Colors.white.withValues(alpha: 0.45), size: 24),
            selectedIcon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
            label: l10n.transactions,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withValues(alpha: 0.45), size: 24),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
            label: l10n.accounts,
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded, color: Colors.white.withValues(alpha: 0.45), size: 22),
            selectedIcon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
            label: l10n.othersTitle,
          ),
        ],
      ),
    );
  }
}
