class Currency {
  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimalDigits = 0,
  });

  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    int? decimalDigits,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimalDigits: decimalDigits ?? this.decimalDigits,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'symbol': symbol,
    'decimalDigits': decimalDigits,
  };

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json['code'] as String,
        name: json['name'] as String,
        symbol: json['symbol'] as String,
        decimalDigits: json['decimalDigits'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
