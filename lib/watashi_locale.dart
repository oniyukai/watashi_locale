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

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

export 'package:watashi_locale/dictionary_delegate.dart';

/// A static utility for centralizing the management of [LocalizationsDelegate] instances.
///
/// Use [register] to inject your custom delegates. This class automatically combines
/// them with [GlobalMaterialLocalizations] delegates, providing a single source
/// for [MaterialApp.localizationsDelegates] and [MaterialApp.supportedLocales].
final class WatashiLocale {
  const WatashiLocale._();

  static final Set<Locale> _supportedLocales = {};

  static final _typeDelegates = {
    for (final delegate in GlobalMaterialLocalizations.delegates)
      delegate.type: delegate
  };

  /// Returns a combined set of all supported locales registered through [register].
  static Set<Locale> get supportedLocales => Set.unmodifiable(_supportedLocales);

  /// Returns a collection of all registered delegates, including default Flutter material delegates.
  static Iterable<LocalizationsDelegate> get localizationsDelegates => _typeDelegates.values;

  /// Registers a list of [WatashiDelegate] instances.
  ///
  /// This will update [supportedLocales] and [localizationsDelegates].
  /// Throws an assertion error if a delegate for the same [LocalizationsDelegate] type is already registered.
  static void register(Iterable<WatashiDelegate> delegates) {
    for (final delegate in delegates) {
      assert(!_typeDelegates.containsKey(delegate.type),
          'A LocalizationsDelegate for <${delegate.type}> is already registered. '
          'To use multiple delegates for the same data type, wrap them in unique [AliasWrapper] subclasses.');
      _typeDelegates[delegate.type] = delegate;
      _supportedLocales.addAll([
        for (final candidate in delegate.localeCandidates)
          if (candidate.locale != null) candidate.locale!
      ]);
    }
  }
}

/// A wrapper used to distinguish localization data by [Type].
///
/// Since Flutter's [Localizations.of] identifies providers by their generic type,
/// using the same class (like `Map<String, String>`) for different features will cause collisions.
///
/// Extend this class to create unique types:
/// ```dart
/// class AuthStrings extends AliasWrapper<MyData> { ... }
/// class MenuStrings extends AliasWrapper<MyData> { ... }
/// ```
abstract class AliasWrapper<T> {
  final T value;

  const AliasWrapper(this.value);
}

/// Represents a candidate for a specific [Locale].
class LocaleCandidate<OPT> {
  /// The container for the provided locale options.
  ///
  /// This field holds the metadata or data source (such as an enum or configuration object)
  /// associated with this [locale].
  final OPT opt;

  final Locale? locale;

  const LocaleCandidate(this.opt, this.locale);
}

/// Defines logic to score how well a [LocaleCandidate] matches a requested [Locale].
///
/// This allows for sophisticated resolution, such as prioritizing a specific
/// country code or falling back to a script-only match.
class LocalizedReferee<LC extends LocaleCandidate> {
  /// A function that returns a matching score. Higher scores take precedence.
  final double Function(LC, Locale) evaluate;

  const LocalizedReferee(this.evaluate);

  /// The standard matching logic.
  ///
  /// Matches language (16.0 pts), script (8.0 pts), and country (4.0 pts).
  factory LocalizedReferee.regular() => LocalizedReferee((candidate, locale) {
    if (candidate.locale == null) return -1.0;
    double score = 0.0;
    if (candidate.locale!.languageCode == locale.languageCode && locale.languageCode.isNotEmpty) score += 16.0;
    if (candidate.locale!.scriptCode == locale.scriptCode && locale.scriptCode?.isNotEmpty == true) score += 8.0;
    if (candidate.locale!.countryCode == locale.countryCode && locale.countryCode?.isNotEmpty == true) score += 4.0;
    return score;
  });
}

/// A highly configurable [LocalizationsDelegate] that uses [LocalizedReferee] to decide
/// which [LC] best fits the user's system locale.
///
/// [AW] (AliasWrapper) is the type of the resulting localized object.
/// [LC] extends [LocaleCandidate] is the type of the candidate holding the locale data.
class WatashiDelegate<AW, LC extends LocaleCandidate> extends LocalizationsDelegate<AW> {
  /// Used if no candidates provide a satisfactory match.
  final LC defaultCandidate;

  /// The list of available candidates (translations) for this delegate.
  final Iterable<LC> localeCandidates;

  /// A function to convert the winning [LC] into the final [AW] instance.
  final AW Function(LC) wrap;

  /// Optional list of custom scoring rules to determine the best locale match.
  final Iterable<LocalizedReferee<LC>>? customReferees;

  /// The default scoring system used if [customReferees] is null.
  final Iterable<LocalizedReferee<LC>> defaultReferees = [LocalizedReferee.regular()];

  WatashiDelegate({
    required this.defaultCandidate,
    required this.localeCandidates,
    required this.wrap,
    this.customReferees,
  }) {
    assert(AW != dynamic, 'The $runtimeType type [AW] must be explicitly specified and cannot be dynamically typed.');
  }

  @override
  bool isSupported(locale) => localeCandidates.any((e) => e.locale?.languageCode == locale.languageCode);

  @override
  bool shouldReload(old) => false;

  @override
  Future<AW> load(locale) {
    Iterable<LC> competitors = localeCandidates;
    for (final referee in customReferees ?? defaultReferees) {
      if (competitors.length <= 1) break;
      final List<LC> winners = [];
      double bestScore = double.negativeInfinity;
      for (final competitor in competitors) {
        final score = referee.evaluate(competitor, locale);
        if (score < bestScore) continue;
        if (score > bestScore) winners.clear();
        winners.add(competitor);
        bestScore = score;
      }
      competitors = winners.isNotEmpty ? winners : [defaultCandidate];
    }
    final winner = competitors.firstOrNull ?? defaultCandidate;
    return SynchronousFuture(wrap(winner));
  }
}
