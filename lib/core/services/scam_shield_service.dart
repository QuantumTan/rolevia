enum ScamRisk { low, medium, high }

class ScamShieldResult {
  const ScamShieldResult({
    required this.risk,
    required this.flags,
    required this.summary,
  });

  final ScamRisk risk;
  final List<String> flags;
  final String summary;

  bool get isSuspicious => risk == ScamRisk.medium || risk == ScamRisk.high;
}

abstract final class ScamShieldService {
  static final RegExp _feePatterns = RegExp(
    r'\b(?:processing fee|registration fee|medical fee|placement fee|uniform fee|cash bond|pay for training|advance payment|send money|payment required)\b',
    caseSensitive: false,
  );

  static final RegExp _chatOnlyPatterns = RegExp(
    r'\b(?:telegram\s*:\s*@|telegram\s+only|dm on telegram|whatsapp\s*:\s*\+?|contact on whatsapp|viber\s+only)\b',
    caseSensitive: false,
  );

  static final RegExp _personalEmailCorporate = RegExp(
    r'\b[a-zA-Z0-9._%+-]+@(gmail|yahoo|hotmail|outlook)\.com\b',
    caseSensitive: false,
  );

  static final RegExp _suspiciousTypingClaims = RegExp(
    r'\b(?:data encoder|typing job|encode captcha|re-typing|copy paste)\b',
    caseSensitive: false,
  );

  static ScamShieldResult evaluate({
    required String role,
    required String company,
    required String overview,
    required int? salaryMin,
    required int? salaryMax,
  }) {
    final flags = <String>[];
    final combined = '$role\n$company\n$overview';

    if (_feePatterns.hasMatch(combined)) {
      flags.add('Asks for upfront payment, processing fee, or cash bond');
    }

    if (_chatOnlyPatterns.hasMatch(combined)) {
      flags.add('Directs hiring communication exclusively to personal messaging apps');
    }

    if (_personalEmailCorporate.hasMatch(combined)) {
      flags.add('Uses free personal email address for corporate recruiter contact');
    }

    if (_suspiciousTypingClaims.hasMatch(combined) && (salaryMin ?? 0) >= 60000) {
      flags.add('Unusually high salary reported for simple non-technical entry tasks');
    }

    if (flags.length >= 2) {
      return ScamShieldResult(
        risk: ScamRisk.high,
        flags: flags,
        summary: 'High risk: Job post exhibits multiple indicators of employment fraud.',
      );
    } else if (flags.length == 1) {
      return ScamShieldResult(
        risk: ScamRisk.medium,
        flags: flags,
        summary: 'Caution: Job post exhibits suspicious hiring or payment terms.',
      );
    }

    return const ScamShieldResult(
      risk: ScamRisk.low,
      flags: [],
      summary: 'Low risk: No fraudulent terms detected.',
    );
  }
}
