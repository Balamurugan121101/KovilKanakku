import 'package:freezed_annotation/freezed_annotation.dart';

part 'donation_model.freezed.dart';
part 'donation_model.g.dart';

@freezed
abstract class DonationModel with _$DonationModel {
  const factory DonationModel({
    required String id,
    required String donorName,
    required double amount,
    String? phone,
    String? purpose,
    String? eventId,
    required DateTime donatedAt,
    required String receiptNumber,
    required String createdBy,
  }) = _DonationModel;

  factory DonationModel.fromJson(Map<String, dynamic> json) =>
      _$DonationModelFromJson(json);
}