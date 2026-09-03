import 'study_session.dart';

/// A computed (not Firestore-stored) aggregation: total study time and
/// session count per subject. Statistics (Step 19) will build a list of
/// these from raw StudySession data rather than querying Firestore
/// per-subject separately — cheaper and keeps aggregation logic in one
/// reusable place instead of duplicated across screens.
class SubjectSessionSummary {
  final String? subjectId;
  final Duration totalDuration;
  final int sessionCount;

  const SubjectSessionSummary({
    required this.subjectId,
    required this.totalDuration,
    required this.sessionCount,
  });

  static List<SubjectSessionSummary> summarize(List<StudySession> sessions) {
    final Map<String?, List<StudySession>> grouped = {};
    for (final session in sessions) {
      grouped.putIfAbsent(session.subjectId, () => []).add(session);
    }

    return grouped.entries.map((entry) {
      final total = entry.value.fold<Duration>(
        Duration.zero,
            (sum, s) => sum + s.duration,
      );
      return SubjectSessionSummary(
        subjectId: entry.key,
        totalDuration: total,
        sessionCount: entry.value.length,
      );
    }).toList()
    // Longest total time first — most-studied subject shown first later.
      ..sort((a, b) => b.totalDuration.compareTo(a.totalDuration));
  }
}