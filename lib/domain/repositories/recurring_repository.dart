import 'package:money_manager/domain/entities/recurring_transaction.dart';

abstract class IRecurringRepository {
  Future<List<RecurringTransaction>> getAllRecurring();
  Stream<List<RecurringTransaction>> watchAllRecurring();
  Stream<List<RecurringTransaction>> watchDueRecurring(DateTime now);
  Future<void> insertRecurring(RecurringTransaction recurring);
  Future<void> updateRecurring(RecurringTransaction recurring);
  Future<void> deleteRecurring(String id);
}

abstract class IRecurringTransactionEntity {
  String get id;
  String get transactionTemplateId;
  String get frequency;
  int get interval;
  DateTime get startDate;
  DateTime? get endDate;
  DateTime get nextOccurrence;
  bool get autoCreate;
  bool get enabled;
  DateTime get createdAt;
  DateTime get updatedAt;
}
