class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final int sourceAmount;
  final int destinationAmount;
  final String currencyCode;
  final double? exchangeRate;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.sourceAmount,
    required this.destinationAmount,
    required this.currencyCode,
    this.exchangeRate,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Transfer copyWith({
    String? id,
    String? fromAccountId,
    String? toAccountId,
    int? sourceAmount,
    int? destinationAmount,
    String? currencyCode,
    double? exchangeRate,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transfer(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      sourceAmount: sourceAmount ?? this.sourceAmount,
      destinationAmount: destinationAmount ?? this.destinationAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromAccountId': fromAccountId,
    'toAccountId': toAccountId,
    'sourceAmount': sourceAmount,
    'destinationAmount': destinationAmount,
    'currencyCode': currencyCode,
    'exchangeRate': exchangeRate,
    'description': description,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Transfer.fromJson(Map<String, dynamic> json) => Transfer(
        id: json['id'] as String,
        fromAccountId: json['fromAccountId'] as String,
        toAccountId: json['toAccountId'] as String,
        sourceAmount: json['sourceAmount'] as int,
        destinationAmount: json['destinationAmount'] as int,
        currencyCode: json['currencyCode'] as String,
        exchangeRate: json['exchangeRate'] as double?,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transfer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
