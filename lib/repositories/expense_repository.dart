import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
  get _expensesCollection {
    return _firestore
        .collection('temples')
        .doc('temple001')
        .collection('expenses');
  }

  Future<ExpenseModel> addExpense({
    required String description,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    String? eventId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final doc = _expensesCollection.doc();

    final expense = ExpenseModel(
      id: doc.id,
      description: description,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      eventId: eventId,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    await doc.set(
      expense.toJson(),
    );

    return expense;
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final snapshot = await _expensesCollection
        .orderBy(
      'date',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => ExpenseModel.fromJson(
        {
          ...doc.data(),
          'id': doc.id,
        },
      ),
    )
        .toList();
  }

  Future<ExpenseModel?> getExpense(
      String expenseId,
      ) async {
    final doc =
    await _expensesCollection.doc(expenseId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return ExpenseModel.fromJson(
      {
        ...doc.data()!,
        'id': doc.id,
      },
    );
  }
}