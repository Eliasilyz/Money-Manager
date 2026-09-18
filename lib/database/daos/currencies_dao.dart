import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/currencies_table.dart';
import 'package:money_manager/database/tables/exchange_rates_table.dart';
import 'package:money_manager/database/database.dart';

part 'currencies_dao.g.dart';

@DriftAccessor(tables: [CurrenciesTable, ExchangeRatesTable])
class CurrenciesDao extends DatabaseAccessor<AppDatabase>
    with _$CurrenciesDaoMixin {
  final AppDatabase db;

  CurrenciesDao(this.db) : super(db);

  Future<int> insertCurrency(CurrenciesTableCompanion currency) =>
      into(currenciesTable).insert(currency, mode: InsertMode.insertOrReplace);

  Future<List<Currency>> getAllCurrencies() => select(currenciesTable).get();

  Future<Currency?> getCurrencyByCode(String code) =>
      (select(currenciesTable)..where((c) => c.code.equals(code)))
          .getSingleOrNull();

  Stream<List<Currency>> watchAllCurrencies() =>
      select(currenciesTable).watch();

  Future<int> insertExchangeRate(ExchangeRatesTableCompanion rate) =>
      into(exchangeRatesTable).insert(rate, mode: InsertMode.insertOrReplace);

  Future<List<ExchangeRate>> getAllExchangeRates() =>
      select(exchangeRatesTable).get();

  Future<ExchangeRate?> getLatestRate(String base, String target) {
    return (select(exchangeRatesTable)
          ..where((r) => r.baseCurrency.equals(base))
          ..where((r) => r.targetCurrency.equals(target))
          ..orderBy([(r) => OrderingTerm.desc(r.date)])
          ..limit(1))
        .getSingleOrNull();
  }
}
