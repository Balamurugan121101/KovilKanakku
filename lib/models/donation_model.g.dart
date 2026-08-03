// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DonationModel _$DonationModelFromJson(Map<String, dynamic> json) =>
    _DonationModel(
      id: json['id'] as String,
      donorName: json['donorName'] as String,
      amount: (json['amount'] as num).toDouble(),
      phone: json['phone'] as String?,
      purpose: json['purpose'] as String?,
      eventId: json['eventId'] as String?,
      donatedAt: DateTime.parse(json['donatedAt'] as String),
      receiptNumber: json['receiptNumber'] as String,
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$DonationModelToJson(_DonationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'donorName': instance.donorName,
      'amount': instance.amount,
      'phone': instance.phone,
      'purpose': instance.purpose,
      'eventId': instance.eventId,
      'donatedAt': instance.donatedAt.toIso8601String(),
      'receiptNumber': instance.receiptNumber,
      'createdBy': instance.createdBy,
    };
