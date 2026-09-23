class ExchangeRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime date;

  const ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.date,
  });
}

double convertAmount(int amount, String from, String to, Map<String, double> rates) {
  if (from == to) return amount.toDouble();
  final direct = rates['$from:$to'];
  if (direct != null) return amount * direct;
  final inverse = rates['$to:$from'];
  if (inverse != null && inverse != 0) return amount / inverse;
  // ponytail: unknown pair falls back to 1:1. Refresh rates in the currency screen to make cross-currency totals exact.
  return amount.toDouble();
}

const defaultCurrencies = [
  ('IDR', 'Indonesian Rupiah', 'Rp', 0),
  ('USD', 'US Dollar', r'$', 2),
  ('EUR', 'Euro', '\u20ac', 2),
  ('GBP', 'British Pound', '\u00a3', 2),
  ('JPY', 'Japanese Yen', '\u00a5', 0),
];

int currencyDigits(String code) {
  for (final (c, _, _, d) in defaultCurrencies) {
    if (c == code) return d;
  }
  return 2;
}

String currencySymbol(String code) {
  for (final (c, _, s, _) in defaultCurrencies) {
    if (c == code) return s;
  }
  return code;
}