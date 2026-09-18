// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currencies_dao.dart';

// ignore_for_file: type=lint
mixin _$CurrenciesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTableTable get currenciesTable => attachedDatabase.currenciesTable;
  $ExchangeRatesTableTable get exchangeRatesTable =>
      attachedDatabase.exchangeRatesTable;
  CurrenciesDaoManager get managers => CurrenciesDaoManager(this);
}

class CurrenciesDaoManager {
  final _$CurrenciesDaoMixin _db;
  CurrenciesDaoManager(this._db);
  $$CurrenciesTableTableTableManager get currenciesTable =>
      $$CurrenciesTableTableTableManager(
          _db.attachedDatabase, _db.currenciesTable);
  $$ExchangeRatesTableTableTableManager get exchangeRatesTable =>
      $$ExchangeRatesTableTableTableManager(
          _db.attachedDatabase, _db.exchangeRatesTable);
}
