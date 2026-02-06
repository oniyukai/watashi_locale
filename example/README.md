# watashi_locale Example Guide

Comprehensive documentation for implementing dictionary-based text translations and generic data localization using watashi_locale.

## Basic for Dictionary

To set up a basic dictionary-based localization system, follow these steps based on the provided example structure:

### 1. Define Data Type and Wrapper Class
Since Flutter looks up `Localizations` based on `Type`, we use an alias class to wrap our dictionary Map, allowing differentiation by type. This is unnecessary if your types are unique.

```dart
typedef DictInstance = Map<DictKey, String?>;

class DictInstanceAlias extends AliasWrapper<DictInstance> {
  const DictInstanceAlias(super.value);

  static late DictInstance _instance;

  // Used to load the current instance synchronously within the BuildContext
  static DictInstance load(BuildContext context) =>
      _instance = Localizations.of<DictInstanceAlias>(context, DictInstanceAlias)!.value;

  // Define the WatashiDictDelegate
  static final delegate = WatashiDictDelegate(
    localeCandidates: LocaleEnum.values.map((e) => DictLocaleCandidate(e, e.locale, e.languageInstance)),
    defaultCandidate: DictLocaleCandidate(LocaleEnum.en, LocaleEnum.en.locale, LocaleEnum.en.languageInstance),
    dictKeys: DictKey.values,
    dictWrap: (value) => DictInstanceAlias(value),
  );
}
```

### 2. Create Keys and Translations
Use `enum` to manage translation keys, and leverage getter extensions for clean usage in the UI. Additionally, it is not limited to using K<enum> or V<String?>.

```dart
enum DictKey {
  deviceDefault,
  title;

  // Getter for easy access in UI widgets
  String get s => DictInstanceAlias._instance[this] ?? '<$name>';
}

const DictInstance enMap = { .deviceDefault: 'Device Default' };
const DictInstance zhMap = { .deviceDefault: '裝置預設' };
```

### 3. Configure Locale Candidates
Define which `Locale` corresponds to which list of dictionaries (supporting fallback via multiple Maps). For convenience, I use an enum to manage them.

```dart
enum LocaleEnum {
  en(Locale('en'), [enMap]),
  zh(Locale('zh'), [zhMap, enMap]); // Fallback to en if key is missing in zh

  final Locale? locale;
  final List<DictInstance> languageInstance;
  const LocaleEnum(this.locale, this.languageInstance);
}
```

### 4. Register and Use
In `void main` or before the first build `initState`, register the delegate with `WatashiLocale`:

```dart
void main() {
  WatashiLocale.register([DictInstanceAlias.delegate]);
  runApp(const MyApp());
}

// In MaterialApp configuration:
MaterialApp(
  locale: currentLocale,
  localizationsDelegates: WatashiLocale.localizationsDelegates,
  supportedLocales: WatashiLocale.supportedLocales,
  home: MyHomePage(),
);
```

## General or Advanced Usage

While `WatashiDictDelegate` is perfect for text translations, the core `WatashiDelegate` is designed to localize **any** data type—such as icons, theme configurations, or asset paths—using a powerful scoring system.

### 1. Localizing Non-Text Data (e.g., Icons)
You can use `WatashiDelegate` to return specific objects based on the locale. For example, if you want to change an icon based on the user's region:

```dart
class GeneralUsage {
  static IconData of(BuildContext context) => Localizations.of<IconData>(context, IconData)!;

  static final delegate = WatashiDelegate<IconData, LocaleCandidate<LocaleEnum>>(
    defaultCandidate: LocaleCandidate(LocaleEnum.sys, LocaleEnum.sys.locale),
    localeCandidates: LocaleEnum.values.map((e) => LocaleCandidate(e, e.locale)),
    wrap: (c) => c.opt.iconData ?? Icons.question_mark,
  );
}
```

### 2. Custom Scoring with LocalizedReferee
The package decides which locale "wins" using `LocalizedReferee`. By default, it scores matches based on Language (16pts), Script (8pts), and Country (4pts).

You can inject `customReferees` to create unique fallback rules or tie-breakers:

### 3. Handling Multiple Delegates of the Same Type
Flutter’s `Localizations.of<T>` identifies data by its Type. If you have two different dictionaries both using `Map<String, String>`, they will collide. To solve this, extend `AliasWrapper`:

### 4. Automatic Integration
When you use `WatashiLocale.register()`, the package automatically:
- Merges your custom delegates with `GlobalMaterialLocalizations`.
- Populates `supportedLocales` by scanning all registered `LocaleCandidate` instances.
- Prevents duplicate delegate registration via internal assertions.

## License

```text
Copyright 2026 ONIYUKAI https://github.com/oniyukai/watashi_locale

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
