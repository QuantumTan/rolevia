enum SkillRelationship { exact, related, none }

class SkillHit {
  const SkillHit(this.canonical, this.start, this.end, this.matchedText);

  final String canonical;
  final int start, end;
  final String matchedText;
}

class _SkillPattern {
  const _SkillPattern(
    this.canonical,
    this.pattern, {
    this.caseSensitive = false,
  });

  final String canonical;
  final String pattern;
  final bool caseSensitive;
}

abstract final class SkillTaxonomy {
  static const List<_SkillPattern> _patterns = [
    _SkillPattern('react_native', r'\breact[ -]?native\b'),
    _SkillPattern('javascript', r'\b(?:javascript|java[ -]?script|js)\b'),
    _SkillPattern('typescript', r'\b(?:typescript|type[ -]?script|ts)\b'),
    _SkillPattern(
      'c_plus_plus',
      r'(?<![A-Za-z0-9])C\+\+(?![A-Za-z0-9])',
      caseSensitive: true,
    ),
    _SkillPattern(
      'c_sharp',
      r'(?<![A-Za-z0-9])C#(?![A-Za-z0-9])',
      caseSensitive: true,
    ),
    _SkillPattern(
      'c_language',
      r'(?<![A-Za-z0-9])C(?: language| programming)?(?![A-Za-z0-9+#])',
      caseSensitive: true,
    ),
    _SkillPattern('java', r'\bjava\b'),
    _SkillPattern(
      'spring',
      r'\b(?:spring boot|spring framework|java spring)\b',
    ),
    _SkillPattern('react', r'\breact(?:\.js|js)?\b'),
    _SkillPattern(
      'go',
      r'\b(?:golang|go language|go developer|go engineer|go programming)\b',
    ),
    _SkillPattern(
      'r_language',
      r'(?<![A-Za-z0-9])R(?: language| programming)?(?![A-Za-z0-9])',
      caseSensitive: true,
    ),
    _SkillPattern('flutter', r'\bflutter\b'),
    _SkillPattern('dart', r'\bdart\b'),
    _SkillPattern('python', r'\bpython\b'),
    _SkillPattern('node_js', r'\b(?:node(?:\.js|js)?|node js)\b'),
    _SkillPattern('kubernetes', r'\b(?:kubernetes|k8s)\b'),
    _SkillPattern(
      'ci_cd',
      r'\b(?:ci\s*/\s*cd|continuous integration|continuous delivery|continuous deployment)\b',
    ),
    _SkillPattern('postgresql', r'\b(?:postgresql|postgres)\b'),
    _SkillPattern('mysql', r'\bmysql\b'),
    _SkillPattern(
      'sql',
      r'(?<![A-Za-z0-9])SQL(?![A-Za-z0-9])',
      caseSensitive: true,
    ),
    _SkillPattern('docker', r'\bdocker\b'),
    _SkillPattern('graphql', r'\bgraphql\b'),
    _SkillPattern('rest_api', r'\b(?:restful|rest api|rest apis)\b'),
    _SkillPattern('aws_lambda', r'\b(?:aws lambda|lambda functions?)\b'),
    _SkillPattern('aws_s3', r'\b(?:amazon s3|aws s3|s3 buckets?)\b'),
    _SkillPattern('aws_ec2', r'\b(?:amazon ec2|aws ec2|ec2 instances?)\b'),
    _SkillPattern('aws', r'\b(?:aws|amazon web services)\b'),
    _SkillPattern('azure', r'\b(?:azure|microsoft azure)\b'),
    _SkillPattern('gcp', r'\b(?:gcp|google cloud platform)\b'),
    _SkillPattern('git', r'\bgit\b'),
    _SkillPattern(
      'customer_support',
      r'\b(?:customer support|customer service|client service|client support|chat support|voice support|non[ -]?voice support|bpo support)\b',
    ),
    _SkillPattern(
      'technical_support',
      r'\b(?:technical support|tech support|help desk|service desk)\b',
    ),
    _SkillPattern(
      'ticketing',
      r'\b(?:ticketing|ticket system|zendesk|freshdesk|service ?now)\b',
    ),
    _SkillPattern(
      'csat',
      r'(?<![A-Za-z0-9])CSAT(?![A-Za-z0-9])',
      caseSensitive: true,
    ),
    _SkillPattern(
      'aht',
      r'(?<![A-Za-z0-9])AHT(?![A-Za-z0-9])',
      caseSensitive: true,
    ),
    _SkillPattern(
      'quality_assurance',
      r'\b(?:quality assurance|qa score|qa monitoring)\b',
    ),
    _SkillPattern(
      'escalation_handling',
      r'\b(?:escalation handling|handled escalations?|customer escalations?|escalated customer|complex cases?)\b',
    ),
    _SkillPattern(
      'communication',
      r'\b(?:communication|communicat(?:e|ed|ing)|pakikipag[ -]?usap)\b',
    ),
    _SkillPattern(
      'problem_solving',
      r'\b(?:problem[ -]?solving|troubleshoot(?:ing|ed)?|root cause analysis)\b',
    ),
  ];

  static const Map<String, Set<String>> _related = {
    'sql': {'mysql', 'postgresql'},
    'mysql': {'sql', 'postgresql'},
    'postgresql': {'sql', 'mysql'},
    'react': {'react_native'},
    'react_native': {'react'},
    'javascript': {'typescript'},
    'typescript': {'javascript'},
    'customer_support': {'technical_support', 'escalation_handling'},
    'technical_support': {'customer_support', 'problem_solving'},
    'aws': {'aws_lambda', 'aws_s3', 'aws_ec2'},
    'aws_lambda': {'aws'},
    'aws_s3': {'aws'},
    'aws_ec2': {'aws'},
  };

  static List<SkillHit> hits(String text) {
    final candidates = <SkillHit>[];
    for (final definition in _patterns) {
      final expression = RegExp(
        definition.pattern,
        caseSensitive: definition.caseSensitive,
      );
      for (final match in expression.allMatches(text)) {
        candidates.add(
          SkillHit(
            definition.canonical,
            match.start,
            match.end,
            match.group(0) ?? '',
          ),
        );
      }
    }
    candidates.sort((left, right) {
      final start = left.start.compareTo(right.start);
      if (start != 0) return start;
      return (right.end - right.start).compareTo(left.end - left.start);
    });

    final selected = <SkillHit>[];
    for (final candidate in candidates) {
      final overlaps = selected.any(
        (hit) => candidate.start < hit.end && candidate.end > hit.start,
      );
      if (!overlaps) selected.add(candidate);
    }
    return selected;
  }

  static Set<String> extract(String text) => {
    for (final hit in hits(text)) hit.canonical,
  };

  static SkillRelationship relationship(String required, String candidate) {
    if (required == candidate) return SkillRelationship.exact;
    if (_related[required]?.contains(candidate) == true) {
      return SkillRelationship.related;
    }
    return SkillRelationship.none;
  }

  static String displayName(String canonical) => switch (canonical) {
    'react_native' => 'React Native',
    'javascript' => 'JavaScript',
    'typescript' => 'TypeScript',
    'c_plus_plus' => 'C++',
    'c_sharp' => 'C#',
    'c_language' => 'C',
    'r_language' => 'R',
    'node_js' => 'Node.js',
    'ci_cd' => 'CI/CD',
    'postgresql' => 'PostgreSQL',
    'mysql' => 'MySQL',
    'rest_api' => 'REST APIs',
    'aws_lambda' => 'AWS Lambda',
    'aws_s3' => 'Amazon S3',
    'aws_ec2' => 'Amazon EC2',
    'gcp' => 'Google Cloud Platform',
    'customer_support' => 'Customer support',
    'technical_support' => 'Technical support',
    'quality_assurance' => 'Quality assurance',
    'escalation_handling' => 'Escalation handling',
    'problem_solving' => 'Problem solving',
    _ =>
      canonical
          .split('_')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' '),
  };
}
