class Debt {
  final String id;
  final String personName;
  final String type;
  final int originalAmount;
  final int remainingAmount;
  final String currencyCode;
  final String? description;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Debt({
    required this.id,
    required this.personName,
    required this.type,
    required this.originalAmount,
    required this.remainingAmount,
    required this.currencyCode,
    this.description,
    required this.dueDate,
    this.status = 'unpaid',
    required this.createdAt,
    required this.updatedAt,
  });

  Debt copyWith({
    String? id,
    String? personName,
    String? type,
    int? originalAmount,
    int? remainingAmount,
    String? currencyCode,
    String? description,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'type': type,
    'originalAmount': originalAmount,
    'remainingAmount': remainingAmount,
    'currencyCode': currencyCode,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'] as String,
        personName: json['personName'] as String,
        type: json['type'] as String,
        originalAmount: json['originalAmount'] as int,
        remainingAmount: json['remainingAmount'] as int,
        currencyCode: json['currencyCode'] as String,
        description: json['description'] as String?,
        dueDate: DateTime.parse(json['dueDate'] as String),
        status: json['status'] as String? ?? 'unpaid',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Debt && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DebtPayment {
  final String id;
  final String debtId;
  final String accountId;
  final int amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const DebtPayment({
    required this.id,
    required this.debtId,
    required this.accountId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  DebtPayment copyWith({
    String? id,
    String? debtId,
    String? accountId,
    int? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return DebtPayment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'debtId': debtId,
    'accountId': accountId,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DebtPayment.fromJson(Map<String, dynamic> json) => DebtPayment(
        id: json['id'] as String,
        debtId: json['debtId'] as String,
        accountId: json['accountId'] as String,
        amount: json['amount'] as int,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtPayment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
