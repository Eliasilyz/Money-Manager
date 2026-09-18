import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/transfer.dart';
import 'package:money_manager/domain/repositories/transaction_repository.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';

class TransfersNotifier extends StateNotifier<AsyncValue<List<Transfer>>> {
  final ITransactionRepository _repo;

  TransfersNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadTransfers();
  }

  Future<void> loadTransfers() async {
    state = const AsyncValue.loading();
    try {
      final transfers = await _repo.getAllTransfers();
      transfers.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transfers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final transfersNotifierProvider = StateNotifierProvider<TransfersNotifier, AsyncValue<List<Transfer>>>((ref) {
  return TransfersNotifier(ref.read(transactionRepositoryProvider));
});
