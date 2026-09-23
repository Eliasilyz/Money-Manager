class RecurringTransaction {
  final String id;
  final String type;
  final String accountId;
  final String? categoryId;
  final int amount;
  final String currencyCode;
  final String? description;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrence;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    required this.id,
    required this.type,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.currencyCode,
    this.description,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    required this.nextOccurrence,
    this.enabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTransaction copyWith({
    String? id,
    String? type,
    String? accountId,
    String? categoryId,
    int? amount,
    String? currencyCode,
    String? description,
    String? frequency,
    int? interval,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextOccurrence,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'accountId': accountId,
    'categoryId': categoryId,
    'amount': amount,
    'currencyCode': currencyCode,
    'description': description,
    'frequency': frequency,
    'interval': interval,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'nextOccurrence': nextOccurrence.toIso8601String(),
    'enabled': enabled,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) => RecurringTransaction(
        id: json['id'] as String,
        type: json['type'] as String,
        accountId: json['accountId'] as String,
        categoryId: json['categoryId'] as String?,
        amount: json['amount'] as int,
        currencyCode: json['currencyCode'] as String,
        description: json['description'] as String?,
        frequency: json['frequency'] as String,
        interval: json['interval'] as int? ?? 1,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        nextOccurrence: DateTime.parse(json['nextOccurrence'] as String),
        enabled: json['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}