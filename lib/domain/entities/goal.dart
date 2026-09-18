class Goal {
  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String currencyCode;
  final String? linkedAccountId;
  final DateTime startDate;
  final DateTime? targetDate;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.currencyCode,
    this.linkedAccountId,
    required this.startDate,
    this.targetDate,
    this.status = 'active',
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Goal copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    String? currencyCode,
    String? linkedAccountId,
    DateTime? startDate,
    DateTime? targetDate,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'currencyCode': currencyCode,
    'linkedAccountId': linkedAccountId,
    'startDate': startDate.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
    'status': status,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: json['targetAmount'] as int,
        currentAmount: json['currentAmount'] as int? ?? 0,
        currencyCode: json['currencyCode'] as String,
        linkedAccountId: json['linkedAccountId'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate'] as String) : null,
        status: json['status'] as String? ?? 'active',
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
