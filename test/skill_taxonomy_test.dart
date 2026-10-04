import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/matching/skill_taxonomy.dart';

void main() {
  test('disambiguates Java, JavaScript, and common C-family tokens', () {
    expect(SkillTaxonomy.extract('Java developer'), {'java'});
    expect(SkillTaxonomy.extract('JavaScript developer'), {'javascript'});
    expect(SkillTaxonomy.extract('Built services in C, C++, and C#.'), {
      'c_language',
      'c_plus_plus',
      'c_sharp',
    });
  });

  test('does not treat ordinary go, spring, or r words as languages', () {
    expect(SkillTaxonomy.extract('We go to market in spring.'), isEmpty);
    expect(SkillTaxonomy.extract('Go developer using the Spring framework'), {
      'go',
      'spring',
    });
    expect(SkillTaxonomy.extract('Built statistical models in R language'), {
      'r_language',
    });
  });

  test('keeps React Native distinct and recognizes abbreviations', () {
    expect(SkillTaxonomy.extract('React Native, TS, K8s, and CI/CD'), {
      'react_native',
      'typescript',
      'kubernetes',
      'ci_cd',
    });
  });

  test('maps related database and support terminology', () {
    expect(
      SkillTaxonomy.relationship('sql', 'postgresql'),
      SkillRelationship.related,
    );
    expect(
      SkillTaxonomy.extract('Handled chat support and customer escalations'),
      containsAll({'customer_support', 'escalation_handling'}),
    );
  });
}
