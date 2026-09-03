/// Centralizes every Firestore collection path as a static helper.
/// Prevents typos like 'subject' vs 'subjects' scattered across the
/// codebase — every repository will import this instead of hardcoding
/// path strings.
class FirestorePaths {
  FirestorePaths._();

  static String userDoc(String userId) => 'users/$userId';
  static String subjects(String userId) => 'users/$userId/subjects';
  static String notes(String userId) => 'users/$userId/notes';
  static String tasks(String userId) => 'users/$userId/tasks';
  static String studySessions(String userId) => 'users/$userId/studySessions';
  static String stats(String userId) => 'users/$userId/stats';
}