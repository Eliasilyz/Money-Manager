import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});
  static const List<String> categoryTypes = ['expense', 'income'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(leading: const CircleAvatar(child: Text('📁')), title: Text(cat.name), subtitle: Text('Type: ${cat.type}'));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'expense');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              DropdownButtonFormField<String>(
                initialValue: 'expense',
                items: categoryTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => typeCtrl.text = val ?? 'expense',
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text;
              final type = typeCtrl.text;
              if (name.isNotEmpty && type.isNotEmpty) {
                ref.read(categoriesNotifierProvider.notifier).addCategory(
                      Category(id: const Uuid().v4(), name: name, type: type, createdAt: DateTime.now(), updatedAt: DateTime.now()),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
