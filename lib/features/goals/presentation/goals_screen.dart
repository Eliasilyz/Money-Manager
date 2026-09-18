import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(child: Text('No goals set. Tap + to create one.'));
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final g = goals[index];
              final progress = g.targetAmount > 0 ? g.currentAmount / g.targetAmount : 0.0;

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(g.status == 'completed' ? Icons.check_circle : Icons.flag),
                ),
                title: Text(g.name),
                subtitle: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                ),
                trailing: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-goal'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
