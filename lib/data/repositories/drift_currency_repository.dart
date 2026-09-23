import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/currency.dart' as domain;
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/repositories/currency_repository.dart';

class DriftCurrencyRepository implements ICurrencyRepository {
  final drift.AppDatabase _db;

  DriftCurrencyRepository(this._db);

  @override
  Future<List<domain.Currency>> getAllCurrencies() async {
    final currencies = await _db.currenciesDao.getAllCurrencies();
    return currencies.map(_toDomain).toList();
  }

  @override
  Future<domain.Currency?> getCurrencyByCode(String code) async {
    final currency = await _db.currenciesDao.getCurrencyByCode(code);
    if (currency == null) return null;
    return domain.Currency(
      code: currency.code,
      name: currency.name,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );
  }

  @override
  Stream<List<domain.Currency>> watchAllCurrencies() =>
      _db.currenciesDao.watchAllCurrencies().map((currencies) =>
          currencies.map(_toDomain).toList());

  @override
  Future<void> insertCurrency(domain.Currency currency) async {
    await _db.currenciesDao.insertCurrency(
      drift.CurrenciesTableCompanion(
        code: Value(currency.code),
        name: Value(currency.name),
        symbol: Value(currency.symbol),
        decimalDigits: Value(currency.decimalDigits),
      ),
    );
  }

  @override
  Future<List<ExchangeRate>> getAllExchangeRates() async {
    final rates = await _db.currenciesDao.getAllExchangeRates();
    return rates
        .map((r) => ExchangeRate(
              baseCurrency: r.baseCurrency,
              targetCurrency: r.targetCurrency,
              rate: r.rate,
              date: r.date,
            ))
        .toList();
  }

  @override
  Future<void> saveExchangeRate(ExchangeRate rate) async {
    await _db.currenciesDao.insertExchangeRate(
      drift.ExchangeRatesTableCompanion(
        baseCurrency: Value(rate.baseCurrency),
        targetCurrency: Value(rate.targetCurrency),
        rate: Value(rate.rate),
        date: Value(rate.date),
      ),
    );
  }

  domain.Currency _toDomain(drift.Currency c) => domain.Currency(
        code: c.code,
        name: c.name,
        symbol: c.symbol,
        decimalDigits: c.decimalDigits,
      );
}
