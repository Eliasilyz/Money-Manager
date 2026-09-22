import 'package:money_manager/domain/entities/recurring_transaction.dart';

abstract class IRecurringRepository {
  Future<List<RecurringTransaction>> getAllRecurring();
  Stream<List<RecurringTransaction>> watchAllRecurring();
  Stream<List<RecurringTransaction>> watchDueRecurring(DateTime now);
  Future<void> insertRecurring(RecurringTransaction recurring);
  Future<void> updateRecurring(RecurringTransaction recurring);
  Future<void> deleteRecurring(String id);
}
