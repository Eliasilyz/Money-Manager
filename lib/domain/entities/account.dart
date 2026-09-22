class Account {
  final String id;
  final String name;
  final String accountType;
  final String currencyCode;
  final int initialBalance;
  final String? icon;
  final String? color;
  final String? note;
  final bool isArchived;
  final int sortOrder;
  final String? systemKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.accountType,
    required this.currencyCode,
    required this.initialBalance,
    this.icon,
    this.color,
    this.note,
    this.isArchived = false,
    this.sortOrder = 0,
    this.systemKey,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    String? accountType,
    String? currencyCode,
    int? initialBalance,
    String? icon,
    String? color,
    String? note,
    bool? isArchived,
    int? sortOrder,
    String? systemKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      currencyCode: currencyCode ?? this.currencyCode,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      note: note ?? this.note,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      systemKey: systemKey ?? this.systemKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'accountType': accountType,
    'currencyCode': currencyCode,
    'initialBalance': initialBalance,
    'icon': icon,
    'color': color,
    'note': note,
    'isArchived': isArchived,
    'sortOrder': sortOrder,
    'systemKey': systemKey,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        accountType: json['accountType'] as String,
        currencyCode: json['currencyCode'] as String,
        initialBalance: json['initialBalance'] as int,
        icon: json['icon'] as String?,
        color: json['color'] as String?,
        note: json['note'] as String?,
        isArchived: json['isArchived'] as bool? ?? false,
        sortOrder: json['sortOrder'] as int? ?? 0,
        systemKey: json['systemKey'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
