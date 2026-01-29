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
import 'package:provider/provider.dart';
import 'package:watashi_locale/watashi_locale.dart';
import 'package:watashi_locale_example/locale/my_locale.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class MyAppProvider extends ChangeNotifier {
  Locale? _locale;
  Locale get locale => _locale ?? WidgetsBinding.instance.platformDispatcher.locale;

  void updateLocale(Locale? newLocale) {
    debugPrint('MyAppProvider.updateLocale($newLocale -> $locale)');
    if (newLocale == _locale && newLocale?.countryCode == _locale?.countryCode) return;
    _locale = newLocale;
    notifyListeners();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WatashiLocale.register([
      GeneralUsage.delegate,
      DictInstanceAlias.delegate,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppProvider>(
      builder: (context, state, child) {
        return MaterialApp(
          title: 'watashi_locale example',
          home: const MyHomePage(),
          locale: state.locale,
          localizationsDelegates: WatashiLocale.localizationsDelegates,
          supportedLocales: WatashiLocale.supportedLocales,
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    DictInstanceAlias.load(context);
    final appProvider = context.read<MyAppProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: Icon(GeneralUsage.of(context)),
        title: Text(DictKey.title.s),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('Current Locale: ${appProvider.locale}'),
            ElevatedButton(
              onPressed: () => appProvider.updateLocale(LocaleEnum.sys.locale),
              child: Text(DictKey.deviceDefault.s),
            ),
            ElevatedButton(
              onPressed: () => showLicensePage(context: context),
              child: Text('showLicensePage'),
            ),
            Row(
              mainAxisSize: .min,
              children: [
                ElevatedButton(
                  onPressed: () => appProvider.updateLocale(LocaleEnum.en.locale),
                  child: Text('${LocaleEnum.en.locale}'),
                ),
                ElevatedButton(
                  onPressed: () => appProvider.updateLocale(LocaleEnum.zhHant.locale),
                  child: Text('${LocaleEnum.zhHant.locale}'),
                ),
                ElevatedButton(
                  onPressed: () => appProvider.updateLocale(LocaleEnum.zhHans.locale),
                  child: Text('${LocaleEnum.zhHans.locale}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
