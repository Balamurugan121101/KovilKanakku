import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Temporary until multi-tenant support is implemented.
  static const String templeId = 'temple001';

  CollectionReference<Map<String, dynamic>>
  get _eventsCollection {
    return _firestore
        .collection('temples')
        .doc(templeId)
        .collection('events');
  }

  // --------------------------------------------------
  // GET ALL EVENTS
  // --------------------------------------------------

  Future<List<EventModel>> getEvents() async {
    final snapshot = await _eventsCollection
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      return EventModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  // --------------------------------------------------
  // GET SINGLE EVENT
  // --------------------------------------------------

  Future<EventModel?> getEvent(
      String eventId,
      ) async {
    final snapshot =
    await _eventsCollection.doc(eventId).get();

    if (!snapshot.exists ||
        snapshot.data() == null) {
      return null;
    }

    return EventModel.fromJson({
      ...snapshot.data()!,
      'id': snapshot.id,
    });
  }

  // --------------------------------------------------
  // ADD EVENT
  // --------------------------------------------------

  Future<EventModel> addEvent({
    required String name,
    required String description,
    required DateTime date,
    required String location,
    required String status,
  }) async {
    final document =
    _eventsCollection.doc();

    final event = EventModel(
      id: document.id,
      name: name,
      description: description,
      date: date,
      location: location,
      status: status,
    );

    await document.set(
      event.toJson(),
    );

    return event;
  }

  // --------------------------------------------------
  // UPDATE EVENT
  // --------------------------------------------------

  Future<void> updateEvent(
      EventModel event,
      ) async {
    await _eventsCollection
        .doc(event.id)
        .set(
      event.toJson(),
      SetOptions(merge: true),
    );
  }

  // --------------------------------------------------
  // DELETE EVENT
  // --------------------------------------------------

  Future<void> deleteEvent(
      String eventId,
      ) async {
    await _eventsCollection
        .doc(eventId)
        .delete();
  }
}