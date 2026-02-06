# watashi_locale

[![GitHub License](https://img.shields.io/github/license/oniyukai/watashi_locale)](https://github.com/oniyukai/watashi_locale/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/oniyukai/watashi_locale.svg)](https://github.com/oniyukai/watashi_locale)

A flexible and lightweight Flutter localization package designed to simplify multi-level fallback dictionaries and custom locale matching.

## Features

- **Weight Comparison Mechanism**: Built-in scoring system automatically selects the optimal language based on the accuracy of language, script, and country code.
- **Multi-Level Dictionary Fallback**: Supports configuring multiple dictionary sources for a single language. When a primary dictionary lacks a specific key, the system automatically searches subsequent dictionaries to fill the gap.
- **Type Isolation Support**: Overcomes Flutter's native locale lookup type constraints, enabling multiple locale instances with identical data structures to coexist within a single app.
- **Streamlined Registration Process**: Provides static tools for unified management of Delegate and Supported Locales, reducing boilerplate code.

## Getting started

> Supported Platforms: `Android`, `iOS`, `Linux`, `MacOS`, `Web`, `Windows`.

Add the dependency in your `pubspec.yaml` using GitHub:

- From GitHub

```yaml
dependencies:
  watashi_locale:
    git:
      url: https://github.com/oniyukai/watashi_locale.git
      ref: main
```

Then run: `flutter pub get`

## Usage

> [!TIP]
> For a complete setup guide or sample code, please refer to the [Example](https://github.com/oniyukai/watashi_locale/tree/main/example).

In the basic dictionary example, after completing approximately 50 lines of configuration code, you can easily maintain and use it within your app.

At the UI level, you can intuitively access translated text:

```dart
@override
Widget build(BuildContext context) {
  // 1. Load the current language instance at the page entry point
  AliasDictInstance.load(context);

  return Scaffold(
    body: Center(
      child: Column(
        children: [
          // 2. Retrieve translations directly via Enum or predefined extension properties
          Text(DictKey.deviceDefault.s),
          Text(DictKey.title.s),
        ],
      ),
    ),
  );
}
```
