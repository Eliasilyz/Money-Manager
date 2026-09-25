import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/recurring/presentation/recurring_form_sheet.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  String _frequencyLabel(String f, AppLocalizations l10n) {
    return switch (f) {
      'daily' => l10n.frequencyDaily,
      'weekly' => l10n.frequencyWeekly,
      'monthly' => l10n.frequencyMonthly,
      'yearly' => l10n.frequencyYearly,
      _ => f,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final asyncItems = ref.watch(recurringTransactionsNotifierProvider);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final categoryById = {for (final c in categories) c.id: c};

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
              l10n.recurring,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.recurringSubtitle,
              style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: () => showRecurringFormSheet(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        l10n.add,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) return _buildEmpty(context, colors, l10n);

          final activeItems = items.where((rt) => rt.enabled).toList();
          final inactiveItems = items.where((rt) => !rt.enabled).toList();

          // Calculate monthly projection (active expenses)
          final projectionExpense = activeItems
              .where((rt) => rt.type == 'expense')
              .fold<int>(0, (s, rt) => s + rt.amount);
          final projectionIncome = activeItems
              .where((rt) => rt.type == 'income')
              .fold<int>(0, (s, rt) => s + rt.amount);

          // Separate subscriptions (monthly expenses with keywords)
          final subscriptions = activeItems.where((rt) {
            final desc = (rt.description ?? '').toLowerCase();
            return rt.type == 'expense' &&
                rt.frequency == 'monthly' &&
                (desc.contains('netflix') ||
                    desc.contains('spotify') ||
                    desc.contains('youtube') ||
                    desc.contains('amazon') ||
                    desc.contains('langganan'));
          }).toList();

          // Upcoming (next 30 days)
          final now = DateTime.now();
          final upcoming = [...activeItems]
            ..sort((a, b) => a.nextOccurrence.compareTo(b.nextOccurrence));
          final upcoming30 = upcoming
              .where((rt) => rt.nextOccurrence.difference(now).inDays <= 30)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // Projection Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [colors.heroCardBg, colors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.heroCardBg.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nextMonthProjection,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '-${formatCurrency(projectionExpense, currencyCode: baseCode)}',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _projectionBadge(
                          icon: Icons.arrow_downward_rounded,
                          label: '+${formatCurrency(projectionIncome, currencyCode: baseCode)}',
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 10),
                        _projectionBadge(
                          icon: Icons.repeat_rounded,
                          label: l10n.activeCount(activeItems.length),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Akan datang (30 hari)
              if (upcoming30.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.upcoming30Days,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.itemsCount(upcoming30.length),
                      style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...upcoming30.map((rt) {
                  final cat = categoryById[rt.categoryId];
                  final title = rt.description?.isNotEmpty == true
                      ? rt.description!
                      : (cat != null ? localizedCategoryName(l10n, cat.systemKey, cat.name) : 'Lainnya');
                  final daysUntil = rt.nextOccurrence.difference(now).inDays;
                  final isIncome = rt.type == 'income';

                  return _buildRecurringTile(
                    context: context,
                    ref: ref,
                    rt: rt,
                    title: title,
                    daysUntil: daysUntil,
                    isIncome: isIncome,
                    baseCode: baseCode,
                    l10n: l10n,
                    colors: colors,
                    showActiveBadge: true,
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Langganan
              if (subscriptions.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.subscriptions,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.activeCount(subscriptions.length),
                      style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...subscriptions.map((rt) {
                  final cat = categoryById[rt.categoryId];
                  final title = rt.description?.isNotEmpty == true
                      ? rt.description!
                      : (cat != null ? localizedCategoryName(l10n, cat.systemKey, cat.name) : 'Langganan');
                  final daysUntil = rt.nextOccurrence.difference(now).inDays;

                  return _buildSubscriptionTile(
                    context: context,
                    ref: ref,
                    rt: rt,
                    title: title,
                    daysUntil: daysUntil,
                    baseCode: baseCode,
                    l10n: l10n,
                    colors: colors,
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Nonaktif items
              if (inactiveItems.isNotEmpty) ...[
                Text(
                  l10n.inactive,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...inactiveItems.map((rt) {
                  final cat = categoryById[rt.categoryId];
                  final title = rt.description?.isNotEmpty == true
                      ? rt.description!
                      : (cat != null ? localizedCategoryName(l10n, cat.systemKey, cat.name) : 'Lainnya');
                  final daysUntil = rt.nextOccurrence.difference(now).inDays;

                  return _buildRecurringTile(
                    context: context,
                    ref: ref,
                    rt: rt,
                    title: title,
                    daysUntil: daysUntil,
                    isIncome: rt.type == 'income',
                    baseCode: baseCode,
                    l10n: l10n,
                    colors: colors,
                    showActiveBadge: false,
                    isInactive: true,
                  );
                }),
              ],
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _projectionBadge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecurringTile({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic rt,
    required String title,
    required int daysUntil,
    required bool isIncome,
    required String baseCode,
    required AppLocalizations l10n,
    required AppColorsT colors,
    required bool showActiveBadge,
    bool isInactive = false,
  }) {
    final amountColor = isIncome ? const Color(0xFF2A9D8F) : const Color(0xFFEF4444);
    final iconBg = isIncome
        ? const Color(0xFFE8F5F3)
        : const Color(0xFFFEE2E2);

    return GestureDetector(
      onTap: () => showRecurringFormSheet(context, edit: rt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isInactive ? colors.surface.withValues(alpha: 0.5) : colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: isInactive
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isInactive ? colors.border : iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isInactive ? colors.textSecondary : amountColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isInactive ? colors.textSecondary : colors.textPrimary,
                          ),
                        ),
                      ),
                      if (showActiveBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.active,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_frequencyLabel(rt.frequency, l10n)} · ${DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode).format(rt.nextOccurrence)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${formatCurrency(rt.amount, currencyCode: baseCode)}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isInactive ? colors.textSecondary : amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Switch(
                  value: rt.enabled,
                  onChanged: (_) => ref.read(recurringTransactionsNotifierProvider.notifier).toggle(rt),
                  activeTrackColor: colors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTile({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic rt,
    required String title,
    required int daysUntil,
    required String baseCode,
    required AppLocalizations l10n,
    required AppColorsT colors,
  }) {
    // Color by subscription name
    final subscriptionColors = <String, Color>{
      'netflix': const Color(0xFFE50914),
      'spotify': const Color(0xFF1DB954),
      'youtube': const Color(0xFFFF0000),
      'amazon': const Color(0xFFFF9900),
    };
    Color cardColor = const Color(0xFF8B5CF6);
    for (final entry in subscriptionColors.entries) {
      if (title.toLowerCase().contains(entry.key)) {
        cardColor = entry.value;
        break;
      }
    }

    return GestureDetector(
      onTap: () => showRecurringFormSheet(context, edit: rt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  title.isNotEmpty ? title[0].toUpperCase() : 'S',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    daysUntil <= 0
                        ? l10n.today
                        : l10n.renewInDays(daysUntil),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: daysUntil <= 3 ? const Color(0xFFD97706) : colors.textSecondary,
                      fontWeight: daysUntil <= 3 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${formatCurrency(rt.amount, currencyCode: baseCode)}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
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
            child: Icon(Icons.repeat_rounded, size: 32, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(l10n.noRecurringTransactions, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          Text(l10n.tapAddRecurring, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}