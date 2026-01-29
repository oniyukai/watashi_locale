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
          'To use multiple delegates for the same data type, wrap them in unique [AliasPackage] subclasses.');
      _typeDelegates[delegate.type] = delegate;
      _supportedLocales.addAll([
        for (final localeAgent in delegate.localeAgents)
          if (localeAgent.locale != null) localeAgent.locale!
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
/// class AuthStrings extends AliasPackage<MyData> { ... }
/// class MenuStrings extends AliasPackage<MyData> { ... }
/// ```
abstract class AliasPackage<T> {
  final T value;

  const AliasPackage(this.value);
}

/// Represents a candidate for a specific [Locale].
class LocaleAgent<OPT> {
  /// The container for the provided locale options.
  ///
  /// This field holds the metadata or data source (such as an enum or configuration object)
  /// associated with this [locale].
  final OPT opt;

  final Locale? locale;

  const LocaleAgent(this.opt, this.locale);
}

/// Defines logic to score how well a [LocaleAgent] matches a requested [Locale].
///
/// This allows for sophisticated resolution, such as prioritizing a specific
/// country code or falling back to a script-only match.
class LocalizedReferee<LA extends LocaleAgent> {
  /// A function that returns a matching score. Higher scores take precedence.
  final double Function(LA, Locale) evaluate;

  const LocalizedReferee(this.evaluate);

  /// The standard matching logic.
  ///
  /// Matches language (16.0 pts), script (8.0 pts), and country (4.0 pts).
  factory LocalizedReferee.regular() => LocalizedReferee((localeAgent, locale) {
    if (localeAgent.locale == null) return -1.0;
    double score = 0.0;
    if (localeAgent.locale!.languageCode == locale.languageCode && locale.languageCode.isNotEmpty) score += 16.0;
    if (localeAgent.locale!.scriptCode == locale.scriptCode && locale.scriptCode?.isNotEmpty == true) score += 8.0;
    if (localeAgent.locale!.countryCode == locale.countryCode && locale.countryCode?.isNotEmpty == true) score += 4.0;
    return score;
  });
}

/// A highly configurable [LocalizationsDelegate] that uses [LocalizedReferee] to decide
/// which [LA] best fits the user's system locale.
///
/// [AP] (AliasPackage) is the type of the resulting localized object.
/// [LA] extends [LocaleAgent] is the type of the agent holding the locale data.
class WatashiDelegate<AP, LA extends LocaleAgent> extends LocalizationsDelegate<AP> {
  /// Used if no agents provide a satisfactory match.
  final LA defaultLocaleAgent;

  /// The list of available agents (translations) for this delegate.
  final Iterable<LA> localeAgents;

  /// Factory to convert the winning [LA] into the final [AP] instance.
  final AP Function(LA) resultFactory;

  /// Optional list of custom scoring rules to determine the best locale match.
  final Iterable<LocalizedReferee<LA>>? customReferees;

  /// The default scoring system used if [customReferees] is null.
  final Iterable<LocalizedReferee<LA>> defaultReferees = [LocalizedReferee.regular()];

  WatashiDelegate({
    required this.defaultLocaleAgent,
    required this.localeAgents,
    required this.resultFactory,
    this.customReferees,
  }) {
    assert(AP != dynamic, 'The $runtimeType type [AP] must be explicitly specified and cannot be dynamically typed.');
  }

  @override
  bool isSupported(locale) => localeAgents.any((e) => e.locale?.languageCode == locale.languageCode);

  @override
  bool shouldReload(old) => false;

  @override
  Future<AP> load(locale) {
    Iterable<LA> competitors = localeAgents;
    for (final referee in customReferees ?? defaultReferees) {
      if (competitors.length <= 1) break;
      final List<LA> winners = [];
      double bestScore = double.negativeInfinity;
      for (final competitor in competitors) {
        final score = referee.evaluate(competitor, locale);
        if (score < bestScore) continue;
        if (score > bestScore) winners.clear();
        winners.add(competitor);
        bestScore = score;
      }
      competitors = winners.isNotEmpty ? winners : [defaultLocaleAgent];
    }
    final winner = competitors.firstOrNull ?? defaultLocaleAgent;
    return SynchronousFuture(resultFactory(winner));
  }
}
