import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/models/subject.dart';


void main() {
  group('Subject.progress', () {
    test('calculates correct percentage', () {
      const subject = Subject(id: '1', name: 'CS', totalChapters: 20, completedChapters: 13);
      expect(subject.progress, closeTo(0.65, 0.001));
    });

    test('returns 0 when totalChapters is 0 (avoids division by zero)', () {
      const subject = Subject(id: '1', name: 'CS', totalChapters: 0, completedChapters: 0);
      expect(subject.progress, 0);
    });

    test('returns 1.0 when fully complete', () {
      const subject = Subject(id: '1', name: 'CS', totalChapters: 10, completedChapters: 10);
      expect(subject.progress, 1.0);
    });
  });
}