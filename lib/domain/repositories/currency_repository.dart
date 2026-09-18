import 'package:money_manager/domain/entities/currency.dart';

abstract class ICurrencyRepository {
  Future<List<Currency>> getAllCurrencies();
  Future<Currency?> getCurrencyByCode(String code);
  Stream<List<Currency>> watchAllCurrencies();
  Future<void> insertCurrency(Currency currency);
}
