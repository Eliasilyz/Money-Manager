import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/data/repositories/drift_account_repository.dart';
import 'package:money_manager/data/repositories/drift_category_repository.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/routing/router.dart';
import 'package:money_manager/theme/app_theme.dart';

void main() {
  final db = AppDatabase();
  final accountRepo = DriftAccountRepository(db);
  final categoryRepo = DriftCategoryRepository(db);

  runApp(
    ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWithValue(accountRepo),
        categoryRepositoryProvider.overrideWithValue(categoryRepo),
      ],
      child: const MoneyManagerApp(),
    ),
  );
}

class MoneyManagerApp extends ConsumerWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
