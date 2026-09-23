import 'package:money_manager/domain/entities/currency.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';

abstract class ICurrencyRepository {
  Future<List<Currency>> getAllCurrencies();
  Future<Currency?> getCurrencyByCode(String code);
  Stream<List<Currency>> watchAllCurrencies();
  Future<void> insertCurrency(Currency currency);
  Future<List<ExchangeRate>> getAllExchangeRates();
  Future<void> saveExchangeRate(ExchangeRate rate);
}