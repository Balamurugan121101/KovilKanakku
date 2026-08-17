import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
abstract class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String name,
    required String description,
    required DateTime date,
    required String location,
    required String status,
  }) = _EventModel;

  factory EventModel.fromJson(
      Map<String, dynamic> json,
      ) => _$EventModelFromJson(json);
}