import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watashi_locale/watashi_locale.dart';

void main() {
  group('Scoring System (LocalizedReferee)', () {
    final referee = LocalizedReferee.regular();

    test('Exact match should score higher than language-only match', () {
      final candidate = LocaleCandidate('test', const Locale('zh', 'TW'));

      final scoreExact = referee.evaluate(candidate, const Locale('zh', 'TW'));
      final scorePartial = referee.evaluate(candidate, const Locale('zh', 'CN'));

      expect(scoreExact > scorePartial, true, reason: 'Exact match (Lang+Country) should be preferred');
    });

    test('Language match should score higher than no match', () {
      final candidate = LocaleCandidate('test', const Locale('en'));
      final scoreMatch = referee.evaluate(candidate, const Locale('en', 'US'));
      final scoreNoMatch = referee.evaluate(candidate, const Locale('fr'));

      expect(scoreMatch > scoreNoMatch, true);
    });
  });

  group('Dictionary Merging (DictionaryDelegate)', () {
    test('Should merge multiple dictionaries and respect priority', () async {
      final primary = {'title': 'Hello'};
      final fallback = {'title': 'Should Not See', 'desc': 'World'};

      final delegate = WatashiDictDelegate<Map, String, String, String>(
        dictKeys: const {'title', 'desc'},
        dictWrap: (map) => map,
        defaultCandidate: DictLocaleCandidate('en', const Locale('en'), [primary, fallback]),
        localeCandidates: [],
      );

      final result = await delegate.load(const Locale('en'));

      expect(result['title'], 'Hello', reason: 'Should take value from the first dictionary');
      expect(result['desc'], 'World', reason: 'Should fallback to second dictionary for missing keys');
    });
  });
}
