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
import 'package:watashi_locale/watashi_locale.dart';

typedef DictInstance = Map<DictKey, String?>;

enum LocaleEnum {
  sys(null, []),
  en(Locale('en'), [enMap], Icons.battery_6_bar),
  zhHant(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'), [zhHantMap, enMap], Icons.battery_4_bar),
  zhHans(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'), [zhHansMap, zhHantMap, enMap], Icons.battery_2_bar);

  final Locale? locale;
  final List<DictInstance> languageInstance;
  final IconData? iconData;

  const LocaleEnum(this.locale, this.languageInstance, [this.iconData]);
}

class GeneralUsage {
  const GeneralUsage._();

  static IconData of(BuildContext context) => Localizations.of<IconData>(context, IconData)!;

  static final delegate = WatashiDelegate(
    defaultCandidate: LocaleCandidate(LocaleEnum.sys, LocaleEnum.sys.locale),
    localeCandidates: LocaleEnum.values.map((e) => LocaleCandidate(e, e.locale)),
    wrap: (e) => e.opt.iconData ?? Icons.question_mark,
  );
}

class DictInstanceAlias extends AliasWrapper<DictInstance> {
  const DictInstanceAlias(super.value);

  static late DictInstance _instance;

  static DictInstance load(BuildContext context) =>
      _instance = Localizations.of<DictInstanceAlias>(context, DictInstanceAlias)!.value;

  static final delegate = WatashiDictDelegate(
    defaultCandidate: DictLocaleCandidate(LocaleEnum.en, LocaleEnum.en.locale, LocaleEnum.en.languageInstance),
    localeCandidates: LocaleEnum.values.map((e) => DictLocaleCandidate(e, e.locale, e.languageInstance)),
    dictKeys: DictKey.values.toSet(),
    dictWrap: (value) => DictInstanceAlias(value),
  );
}

enum DictKey {
  deviceDefault,
  title;

  String get s => DictInstanceAlias._instance[this] ?? '<$name>';
}

const DictInstance enMap = {
  .deviceDefault: 'Device Default',
  .title: 'watashi_locale example Home Page',
};
const DictInstance zhHantMap = {
      .deviceDefault: '裝置預設',
      .title: 'watashi_locale 事例首頁',
};
const DictInstance zhHansMap = {
  .deviceDefault: '设备默认',
};
