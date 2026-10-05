import 'dart:convert';
import 'dart:io';

class MatchingFixture {
  const MatchingFixture({
    required this.id,
    required this.name,
    required this.scenario,
    required this.description,
    required this.jobText,
    required this.resumeText,
    this.referenceDate,
    required this.expectedVerdicts,
    required this.minScore,
    required this.maxScore,
    this.expectedConfidence,
    this.expectedFlags = const {},
  });

  final String id;
  final String name;
  final String scenario;
  final String description;
  final String jobText;
  final String resumeText;
  final DateTime? referenceDate;
  final Map<String, String> expectedVerdicts;
  final int minScore;
  final int maxScore;
  final String? expectedConfidence;
  final Map<String, bool> expectedFlags;

  factory MatchingFixture.fromJson(Map<String, dynamic> json) {
    final scoreRange =
        json['expectedScoreRange'] as Map<String, dynamic>? ?? {};
    return MatchingFixture(
      id: json['id'] as String,
      name: json['name'] as String,
      scenario: json['scenario'] as String? ?? json['name'] as String,
      description: json['description'] as String? ?? '',
      jobText: json['jobText'] as String,
      resumeText: json['resumeText'] as String,
      referenceDate: json['referenceDate'] != null
          ? DateTime.parse(json['referenceDate'] as String)
          : null,
      expectedVerdicts:
          (json['expectedVerdicts'] as Map<String, dynamic>? ?? {}).map(
            (k, v) => MapEntry(k, v.toString()),
          ),
      minScore: (scoreRange['min'] as num?)?.toInt() ?? 0,
      maxScore: (scoreRange['max'] as num?)?.toInt() ?? 100,
      expectedConfidence: json['expectedConfidence'] as String?,
      expectedFlags: (json['expectedFlags'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, v == true),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scenario': scenario,
    'description': description,
    'jobText': jobText,
    'resumeText': resumeText,
    if (referenceDate != null)
      'referenceDate': referenceDate!.toIso8601String(),
    'expectedVerdicts': expectedVerdicts,
    'expectedScoreRange': {'min': minScore, 'max': maxScore},
    if (expectedConfidence != null) 'expectedConfidence': expectedConfidence,
    'expectedFlags': expectedFlags,
  };
}

class MatchingFixtureLoader {
  static List<MatchingFixture> loadAll({
    String directoryPath = 'test/fixtures/matching',
  }) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      throw StateError('Fixture directory does not exist: $directoryPath');
    }
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    return files.map((file) {
      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return MatchingFixture.fromJson(data);
    }).toList();
  }

  static MatchingFixture loadById(
    String id, {
    String directoryPath = 'test/fixtures/matching',
  }) {
    return loadAll(directoryPath: directoryPath).firstWhere(
      (f) => f.id == id,
      orElse: () => throw ArgumentError('Fixture with id "$id" not found'),
    );
  }
}
