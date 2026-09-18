class RecurringTransaction {
  final String id;
  final String transactionTemplateId;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrence;
  final bool autoCreate;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    required this.id,
    required this.transactionTemplateId,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    required this.nextOccurrence,
    this.autoCreate = true,
    this.enabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTransaction copyWith({
    String? id,
    String? transactionTemplateId,
    String? frequency,
    int? interval,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextOccurrence,
    bool? autoCreate,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      transactionTemplateId: transactionTemplateId ?? this.transactionTemplateId,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      autoCreate: autoCreate ?? this.autoCreate,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionTemplateId': transactionTemplateId,
    'frequency': frequency,
    'interval': interval,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'nextOccurrence': nextOccurrence.toIso8601String(),
    'autoCreate': autoCreate,
    'enabled': enabled,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) => RecurringTransaction(
        id: json['id'] as String,
        transactionTemplateId: json['transactionTemplateId'] as String,
        frequency: json['frequency'] as String,
        interval: json['interval'] as int? ?? 1,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        nextOccurrence: DateTime.parse(json['nextOccurrence'] as String),
        autoCreate: json['autoCreate'] as bool? ?? true,
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
