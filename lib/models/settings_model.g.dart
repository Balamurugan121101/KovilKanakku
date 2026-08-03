// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    _SettingsModel(
      templeName: json['templeName'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      receiptPrefix: json['receiptPrefix'] as String,
      nextReceiptNumber: (json['nextReceiptNumber'] as num).toInt(),
    );

Map<String, dynamic> _$SettingsModelToJson(_SettingsModel instance) =>
    <String, dynamic>{
      'templeName': instance.templeName,
      'address': instance.address,
      'phone': instance.phone,
      'receiptPrefix': instance.receiptPrefix,
      'nextReceiptNumber': instance.nextReceiptNumber,
    };
