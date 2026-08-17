import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
abstract class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String id,
    required String description,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    String? eventId,
    required String createdBy,
    required DateTime createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$ExpenseModelFromJson(json);
}