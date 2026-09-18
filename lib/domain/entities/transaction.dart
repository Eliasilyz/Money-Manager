class Transaction {
  final String id;
  final String type;
  final String accountId;
  final String? categoryId;
  final int amount;
  final String currencyCode;
  final String? description;
  final DateTime date;
  final String? note;
  final String? transferId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.currencyCode,
    this.description,
    required this.date,
    this.note,
    this.transferId,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? type,
    String? accountId,
    String? categoryId,
    int? amount,
    String? currencyCode,
    String? description,
    DateTime? date,
    String? note,
    String? transferId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      description: description ?? this.description,
      date: date ?? this.date,
      note: note ?? this.note,
      transferId: transferId ?? this.transferId,
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
    'date': date.toIso8601String(),
    'note': note,
    'transferId': transferId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: json['type'] as String,
        accountId: json['accountId'] as String,
        categoryId: json['categoryId'] as String?,
        amount: json['amount'] as int,
        currencyCode: json['currencyCode'] as String,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
        transferId: json['transferId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
