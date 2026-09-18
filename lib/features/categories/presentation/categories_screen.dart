import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _icons = {
    'food & drinks': ('🍜', AppColors.coral),
    'makanan': ('🍜', AppColors.coral),
    'transport': ('🚗', AppColors.blue),
    'transportasi': ('🚗', AppColors.blue),
    'shopping': ('🛒', AppColors.violet),
    'belanja': ('🛒', AppColors.violet),
    'bills & utilities': ('💡', AppColors.coral),
    'tagihan': ('💡', AppColors.coral),
    'entertainment': ('🎮', AppColors.violet),
    'hiburan': ('🎮', AppColors.violet),
    'health': ('🏥', AppColors.emerald),
    'kesehatan': ('🏥', AppColors.emerald),
    'education': ('📚', AppColors.amber),
    'pendidikan': ('📚', AppColors.amber),
    'salary': ('💼', AppColors.emerald),
    'gaji': ('💼', AppColors.emerald),
    'freelance': ('💻', AppColors.blue),
    'investment': ('📈', AppColors.violet),
    'investasi': ('📈', AppColors.violet),
    'other income': ('💰', AppColors.emerald),
    'pendapatan lain': ('💰', AppColors.emerald),
  };

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
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.coral))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-category'),
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.bg,
        icon: const Icon(Icons.add),
        label: Text('Tambah Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildList(BuildContext context, List categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📂', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Belum ada kategori', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final lookup = _icons[cat.name.toLowerCase()];
        final emoji = lookup?.$1 ?? '📁';
        final color = lookup?.$2 ?? AppColors.textMuted;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: Card(
            child: Dismissible(
              key: ValueKey(cat.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Kategori?'),
                    content: Text('"${cat.name}" akan dihapus permanen.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Hapus', style: GoogleFonts.inter(color: AppColors.coral)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                ref.read(categoriesNotifierProvider.notifier).deleteCategory(cat.id);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
                ),
                title: Text(
                  cat.name,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  cat.type.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cat.type == 'expense' ? AppColors.coral : AppColors.emerald,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
