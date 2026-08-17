import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../models/expense_model.dart';
import '../../../providers/expense_provider.dart';

class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({super.key});

  @override
  ConsumerState<ExpenseListPage> createState() =>
      _ExpenseListPageState();
}

class _ExpenseListPageState
    extends ConsumerState<ExpenseListPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _filterExpenses(
      List<ExpenseModel> expenses,
      ) {
    if (_searchText.isEmpty) {
      return expenses;
    }

    return expenses.where((expense) {
      return expense.description
          .toLowerCase()
          .contains(_searchText) ||
          expense.category
              .toLowerCase()
              .contains(_searchText) ||
          (expense.notes ?? '')
              .toLowerCase()
              .contains(_searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync =
    ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),

      body: expensesAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Unable to load expenses',
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      expensesProvider,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },

        data: (expenses) {
          final filteredExpenses =
          _filterExpenses(expenses);

          final totalAmount =
          expenses.fold<double>(
            0,
                (total, expense) =>
            total + expense.amount,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(
                            Icons.money_off,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expenses',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '₹ ',
                                decimalDigits: 2
                              ).format(totalAmount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                    'Search expense or category...',
                    prefixIcon:
                    const Icon(Icons.search),
                    suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                      ),
                      onPressed: () {
                        _searchController
                            .clear();
                      },
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                  child: Text(
                    _searchText.isEmpty
                        ? 'No expenses found'
                        : 'No matching expenses',
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      expensesProvider,
                    );

                    await ref.read(
                      expensesProvider.future,
                    );
                  },
                  child: ListView.builder(
                    padding:
                    const EdgeInsets.only(
                      bottom: 90,
                    ),
                    itemCount:
                    filteredExpenses.length,
                    itemBuilder:
                        (context, index) {
                      final expense =
                      filteredExpenses[
                      index];

                      return _ExpenseCard(
                        expense: expense,
                        onTap: () {
                          context.push(
                            AppRoutes
                                .expenseDetails,
                            extra: expense,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async {
          await context.push(
            AppRoutes.addExpense,
          );

          ref.invalidate(
            expensesProvider,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Expense'),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.onTap,
  });

  final ExpenseModel expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd MMM yyyy',
    ).format(expense.date);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      child: ListTile(
        onTap: onTap,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          child: Icon(
            _categoryIcon(
              expense.category,
            ),
          ),
        ),

        title: Text(
          expense.description,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Padding(
          padding:
          const EdgeInsets.only(top: 5),
          child: Text(
            '${expense.category} • $date',
          ),
        ),

        trailing: Text(
          NumberFormat.currency(
            locale: 'en_IN',
            symbol: '₹ ',
            decimalDigits: 2,
          ).format(expense.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Pooja':
        return Icons.temple_hindu;

      case 'Flowers':
        return Icons.local_florist;

      case 'Electricity':
        return Icons.electric_bolt;

      case 'Maintenance':
        return Icons.build;

      case 'Food / Annadhanam':
        return Icons.restaurant;

      case 'Salary':
        return Icons.people;

      case 'Cleaning':
        return Icons.cleaning_services;

      case 'Event':
        return Icons.event;

      default:
        return Icons.receipt_long;
    }
  }
}