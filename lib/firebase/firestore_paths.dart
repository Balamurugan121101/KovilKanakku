class FirestorePaths {
  FirestorePaths._();

  static const String templeId = 'temple001';

  static const String temples = 'temples';

  static String temple() => '$temples/$templeId';

  static String settings() => '${temple()}/settings';

  static String users() => '${temple()}/users';

  static String donations() => '${temple()}/donations';

  static String expenses() => '${temple()}/expenses';

  static String events() => '${temple()}/events';
}