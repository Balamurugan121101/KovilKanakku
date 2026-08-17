import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';
import '../repositories/event_repository.dart';

final eventRepositoryProvider =
Provider<EventRepository>(
      (ref) => EventRepository(),
);

final eventsProvider =
FutureProvider<List<EventModel>>(
      (ref) {
    return ref
        .read(eventRepositoryProvider)
        .getEvents();
  },
);

final eventByIdProvider =
FutureProvider.family<EventModel?, String>(
      (ref, eventId) {
    return ref
        .read(eventRepositoryProvider)
        .getEvent(eventId);
  },
);