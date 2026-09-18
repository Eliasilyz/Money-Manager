import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:uuid/uuid.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _nameCtrl = TextEditingController();
  String _type = 'expense';
  bool _saving = false;

  static const _presetCategories = [
    ('Food & Drinks', Icons.restaurant),
    ('Transport', Icons.directions_car),
    ('Shopping', Icons.shopping_bag),
    ('Bills & Utilities', Icons.receipt),
    ('Entertainment', Icons.movie),
    ('Health', Icons.local_hospital),
    ('Education', Icons.school),
    ('Salary', Icons.work),
    ('Freelance', Icons.laptop),
    ('Investment', Icons.trending_up),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (sel) => setState(() => _type = sel.first),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Groceries',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            Text('Quick Add', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetCategories.map((p) {
                return ActionChip(
                  avatar: Icon(p.$2, size: 16),
                  label: Text(p.$1),
                  onPressed: () {
                    _nameCtrl.text = p.$1;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving...' : 'Save Category'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final category = Category(
        id: const Uuid().v4(),
        name: name,
        type: _type,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(categoriesNotifierProvider.notifier).addCategory(category);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
