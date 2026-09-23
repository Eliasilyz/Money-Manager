import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/budgets/presentation/budget_form_sheet.dart';
import 'package:money_manager/features/budgets/presentation/budgets_screen.dart';
import 'package:money_manager/features/goals/presentation/goal_form_sheet.dart';
import 'package:money_manager/features/goals/presentation/goals_screen.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

/// Combined screen: Anggaran | Target tabs.
class BudgetsGoalsScreen extends StatefulWidget {
  const BudgetsGoalsScreen({super.key});

  @override
  State<BudgetsGoalsScreen> createState() => _BudgetsGoalsScreenState();
}

class _BudgetsGoalsScreenState extends State<BudgetsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          l10n.budgetsAndGoals,
          style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => _tab == 0 ? showBudgetFormSheet(context) : showGoalFormSheet(context),
            child: Text(
              _tab == 0 ? l10n.addBudget : l10n.addTarget,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primary),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          indicatorWeight: 2,
          labelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l10n.budgetsTitle),
            Tab(text: l10n.savingsTarget),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BudgetsScreen(paneOnly: true),
          GoalsScreen(paneOnly: true),
        ],
      ),
    );
  }
}
