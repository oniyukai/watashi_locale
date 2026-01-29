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

/// An agent that manages multiple dictionaries for a single locale.
class LocaleAgentGetDict<OPT, K, V> extends LocaleAgent<OPT> {
  /// A collection of maps containing localized key-value pairs.
  final Iterable<Map<K, V?>> dictionaries;

  const LocaleAgentGetDict(super.opt, super.locale, this.dictionaries);
}

/// A specialized delegate for dictionary-based localization.
///
/// It merges values from multiple dictionaries within the winning [LocaleAgentGetDict].
/// It prioritizes agents that have the highest "completion rate" for the required [dictKeys].
class WatashiDictDelegate<AP, OPT, K, V> extends WatashiDelegate<AP, LocaleAgentGetDict<OPT, K ,V>> {
  /// The full list of keys that this delegate is expected to provide.
  final Iterable<K> dictKeys;

  /// A function that wraps the final merged Map into the [AP] instance.
  final AP Function(Map<K, V?>) packager;

  WatashiDictDelegate({
    required super.defaultLocaleAgent,
    required super.localeAgents,
    required this.dictKeys,
    required this.packager,
    super.customReferees,
  }) : super(
      resultFactory: (winner) => packager({
        for (final key in dictKeys)
          key: winner.dictionaries.firstWhereOrNull((map) =>
          map[key] != null)?[key],
      })
  );

  /// 1. Ensure the agent actually has dictionaries.
  /// 2. Standard locale matching.
  /// 3. Completion tie-breaker: If two agents match the locale, pick the one with more filled keys
  /// and fewer fragmented dictionary layers.
  @override
  Iterable<LocalizedReferee<LocaleAgentGetDict<OPT, K ,V>>> get defaultReferees => [
    LocalizedReferee((lad, _) => lad.dictionaries.isEmpty ? -1.0 : 1.0),
    ...super.defaultReferees,
    LocalizedReferee((lad, _) => 1.0 / lad.dictionaries.length +
        lad.dictionaries.first.entries.where((a) => a.value != null).length / dictKeys.length,
    ),
  ];
}
