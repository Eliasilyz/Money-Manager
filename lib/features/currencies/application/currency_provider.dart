import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/currency.dart';
import 'package:money_manager/domain/repositories/currency_repository.dart';

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
    const defaults = [
      Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', decimalDigits: 0),
      Currency(code: 'USD', name: 'US Dollar', symbol: '\$', decimalDigits: 2),
      Currency(code: 'EUR', name: 'Euro', symbol: '\u20ac', decimalDigits: 2),
      Currency(code: 'GBP', name: 'British Pound', symbol: '\u00a3', decimalDigits: 2),
      Currency(code: 'JPY', name: 'Japanese Yen', symbol: '\u00a5', decimalDigits: 0),
    ];
    for (final c in defaults) {
      await _repo.insertCurrency(c);
    }
  }
}

final currenciesNotifierProvider = StateNotifierProvider<CurrenciesNotifier, AsyncValue<List<Currency>>>((ref) {
  return CurrenciesNotifier(ref.read(currencyRepositoryProvider));
});
