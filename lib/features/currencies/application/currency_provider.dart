import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:money_manager/domain/entities/currency.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/repositories/currency_repository.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';

final currencyRepositoryProvider = Provider<ICurrencyRepository>((ref) {
  throw UnimplementedError('CurrencyRepository not initialized');
});

class CurrenciesNotifier extends StateNotifier<AsyncValue<List<Currency>>> {
  final ICurrencyRepository _repo;

  CurrenciesNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final currencies = await _repo.getAllCurrencies();
      if (currencies.isEmpty) {
        await _seedDefaults();
        final seeded = await _repo.getAllCurrencies();
        state = AsyncValue.data(seeded);
      } else {
        state = AsyncValue.data(currencies);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _seedDefaults() async {
    const defaults = defaultCurrencies;
    for (final (code, name, symbol, digits) in defaults) {
      await _repo.insertCurrency(Currency(code: code, name: name, symbol: symbol, decimalDigits: digits));
    }
  }
}

final currenciesNotifierProvider = StateNotifierProvider<CurrenciesNotifier, AsyncValue<List<Currency>>>((ref) {
  return CurrenciesNotifier(ref.read(currencyRepositoryProvider));
});

final currencyByCodeProvider = FutureProvider<Map<String, Currency>>((ref) async {
  final currencies = await ref.read(currencyRepositoryProvider).getAllCurrencies();
  return {for (final c in currencies) c.code: c};
});

final ratesRefreshTickProvider = StateProvider<int>((ref) => 0);

final exchangeRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  ref.watch(ratesRefreshTickProvider);
  final repo = ref.read(currencyRepositoryProvider);
  final all = await repo.getAllExchangeRates();
  all.sort((a, b) => b.date.compareTo(a.date));
  final latest = <String, ExchangeRate>{};
  for (final r in all) {
    latest.putIfAbsent('${r.baseCurrency}:${r.targetCurrency}', () => r);
  }
  return {for (final e in latest.entries) e.key: e.value.rate};
});

// ponytail: refresh is manual-only; auto-fetch on app start can be added when offline-first matters.
final refreshExchangeRatesProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(currencyRepositoryProvider);
  final base = ref.watch(baseCurrencyCodeProvider);
  final known = (await repo.getAllCurrencies()).map((c) => c.code).toSet();
  final res = await http
      .get(Uri.parse('https://open.er-api.com/v6/latest/$base'))
      .timeout(const Duration(seconds: 15));
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode} dari server kurs');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  final rates = (data['rates'] as Map<String, dynamic>?) ?? const {};
  final now = DateTime.now();
  for (final code in known) {
    final r = rates[code];
    if (r is num) {
      await repo.saveExchangeRate(ExchangeRate(baseCurrency: base, targetCurrency: code, rate: r.toDouble(), date: now));
    }
  }
  ref.read(ratesRefreshTickProvider.notifier).state++;
  return known.length;
});