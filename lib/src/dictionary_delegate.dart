// Copyright 2026 ONIYUKAI https://github.com/oniyukai/watashi_locale
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:collection/collection.dart';
import 'package:watashi_locale/watashi_locale.dart';

/// A candidate that manages multiple dictionaries for a single locale.
class DictLocaleCandidate<OPT, K, V> extends LocaleCandidate<OPT> {
  /// A collection of maps containing localized key-value pairs.
  final Iterable<Map<K, V?>> dictionaries;

  const DictLocaleCandidate(super.opt, super.locale, this.dictionaries);
}

/// A specialized delegate for dictionary-based localization.
///
/// It merges values from multiple dictionaries within the winning [DictLocaleCandidate].
/// It prioritizes candidates that have the highest "completion rate" for the required [dictKeys].
class WatashiDictDelegate<AW, OPT, K, V> extends WatashiDelegate<AW, DictLocaleCandidate<OPT, K ,V>> {
  /// The full list of keys that this delegate is expected to provide.
  final Set<K> dictKeys;

  /// A function that wraps the final merged Map into the [AW] instance.
  final AW Function(Map<K, V?>) dictWrap;

  WatashiDictDelegate({
    required super.defaultCandidate,
    required super.localeCandidates,
    required this.dictKeys,
    required this.dictWrap,
    super.customReferees,
  }) : super(
      wrap: (winner) => dictWrap({
        for (final key in dictKeys)
          key: winner.dictionaries.firstWhereOrNull((map) => map[key] != null)?[key],
      })
  );

  /// 1. Ensure the candidate actually has dictionaries.
  /// 2. Standard locale matching.
  /// 3. Completion tie-breaker: If two candidates match the locale, pick the one with more filled keys
  /// and fewer fragmented dictionary layers.
  @override
  Iterable<LocalizedReferee<DictLocaleCandidate<OPT, K ,V>>> get defaultReferees => [
    LocalizedReferee((candidate, _) => candidate.dictionaries.isEmpty ? -1.0 : 1.0),
    ...super.defaultReferees,
    LocalizedReferee((candidate, _) => 1.0 / candidate.dictionaries.length +
        candidate.dictionaries.first.entries.where((e) => e.value != null && dictKeys.contains(e.key)).length / dictKeys.length,
    ),
  ];
}
