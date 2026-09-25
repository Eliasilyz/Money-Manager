import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:money_manager/theme/app_theme.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColorsT.of(context);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        title: Text(
          l10n.categories,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          indicatorWeight: 2,
          tabs: [
            Tab(text: l10n.expense),
            Tab(text: l10n.income),
          ],
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildList(context, categories.where((c) => c.type == 'expense').toList()),
              _buildList(context, categories.where((c) => c.type == 'income').toList()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'categories_fab',
        onPressed: () => context.push('/add-category'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Category> categories) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📂', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(l10n.noData, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Dismissible(
          key: ValueKey(cat.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('${l10n.delete}?'),
                content: Text('${localizedCategoryName(l10n, cat.systemKey, cat.name)} ${l10n.delete}'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l10n.delete, style: GoogleFonts.inter(color: AppColors.rose)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            ref.read(categoriesNotifierProvider.notifier).deleteCategory(cat.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                  child: Icon(
                    cat.icon != null && int.tryParse(cat.icon!) != null
                        // ignore: non_const_argument_for_const_parameter
                        ? IconData(int.parse(cat.icon!), fontFamily: 'MaterialIcons')
                        : Icons.category_outlined,
                    color: colors.primary,
                  size: 18,
                ),
              ),
              title: Text(localizedCategoryName(l10n, cat.systemKey, cat.name), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        );
      },
    );
  }
}
