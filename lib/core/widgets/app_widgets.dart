import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

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
    final label = DateFormat('MMMM yyyy', locale).format(month);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textPrimary)),
            const SizedBox(width: 4),
            Icon(Icons.calendar_today_outlined, size: 14, color: colors.textSecondary),
          ],
        ),
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

  String _resolvedTitle() {
    if (title != null && title!.isNotEmpty) return title!;
    if (isTransfer) {
      final from = fromAccountName ?? '?';
      final to = toAccountName ?? '?';
      return 'Transfer: $from → $to';
    }
    if (note != null && note!.isNotEmpty) return note!;
    if (categoryName != null && categoryName!.isNotEmpty) return categoryName!;
    return isIncome ? 'Pemasukan' : 'Pengeluaran';
  }

  String _resolvedSubtitle(String locale) {
    final parts = <String>[];
    if (isTransfer) {
      final from = fromAccountName ?? '?';
      final to = toAccountName ?? '?';
      parts.add('$from → $to');
    } else {
      if (categoryName != null && categoryName!.isNotEmpty) parts.add(categoryName!);
      if (accountName != null && accountName!.isNotEmpty) parts.add(accountName!);
    }
    parts.add(_formatDate(date, locale));
    return parts.where((p) => p.isNotEmpty).join(' • ');
  }

  static String _formatDate(DateTime? d, [String locale = 'id']) {
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(d.year, d.month, d.day);
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    if (txDay == today) return 'Hari ini • $timeStr';
    if (txDay == today.subtract(const Duration(days: 1))) return 'Kemarin • $timeStr';
    final monthStr = DateFormat('MMM', locale).format(d);
    return '${d.day} $monthStr ${d.year.toString().substring(2)} • $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final color = isIncome ? colors.income : colors.expense;
    final locale = Localizations.localeOf(context).languageCode;

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
        title: Text(_resolvedTitle(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_resolvedSubtitle(locale), style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
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
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      backgroundColor: const Color(0xFF0E3B2B),
      indicatorColor: Colors.white.withValues(alpha: 0.15),
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(index),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 64,
      destinations: [
        NavigationDestination(icon: const Icon(Icons.home_outlined, color: Color(0xFF999999)), selectedIcon: const Icon(Icons.home, color: Colors.white), label: l10n.dashboard),
        NavigationDestination(icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF999999)), selectedIcon: const Icon(Icons.receipt_long, color: Colors.white), label: l10n.transactions),
        NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF999999)), selectedIcon: const Icon(Icons.account_balance_wallet, color: Colors.white), label: l10n.accounts),
        NavigationDestination(icon: const Icon(Icons.more_horiz_outlined, color: Color(0xFF999999)), selectedIcon: const Icon(Icons.more_horiz, color: Colors.white), label: l10n.settings),
      ],
    );
  }
}
