import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

final expenseRepositoryProvider =
Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expensesProvider =
FutureProvider<List<ExpenseModel>>((ref) async {
  final repository =
  ref.read(expenseRepositoryProvider);

  return repository.getExpenses();
});