import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _defaultIcons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'bills': Icons.receipt,
    'entertainment': Icons.movie,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'salary': Icons.work,
    'freelance': Icons.laptop,
    'investment': Icons.trending_up,
    'other': Icons.more_horiz,
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
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Expense', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Income', icon: Icon(Icons.arrow_downward)),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-category'),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildList(BuildContext context, List categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No categories yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final icon = _defaultIcons[cat.name.toLowerCase().replaceAll(' ', '')] ?? Icons.category;
        return Card(
          child: Dismissible(
            key: ValueKey(cat.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Category?'),
                  content: Text('"${cat.name}" will be permanently deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) {
              ref.read(categoriesNotifierProvider.notifier).deleteCategory(cat.id);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cat.type == 'expense'
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Icon(icon, color: cat.type == 'expense' ? Colors.red : Colors.green),
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(cat.type.toUpperCase(), style: TextStyle(
                fontSize: 11,
                color: cat.type == 'expense' ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
        );
      },
    );
  }
}
