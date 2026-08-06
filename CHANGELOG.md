## 0.1.0 (2026.08.07)

- **Breaking**: `getDelegates` now accepts `withGlobal` as a named parameter instead of a positional one; use `getDelegates(withGlobal: false)`.
- `supportedLocales` now returns a fresh copy of the registered locales instead of an unmodifiable view.
- Migrated the example app to newer Flutter tooling and refreshed transitive dependencies.
- Reformatted the library, example, and tests; fixed the example widget test setup.
- Improved documentation across the README, example guide, and API doc comments.

## 0.0.3 (2026.04.04)

- Changed `localizationsDelegates` to `getDelegates`; `GlobalMaterialLocalizations` is now optional.

## 0.0.2 (2026.02.07)

- Rename variables, objects, and more.

## 0.0.1 (2026.01.30)

* **Initial Release**
* Core functionality: locale matching logic based on a weighted scoring system.
* Supports merging multiple dictionaries to enable flexible key-value translation fallback.
* Resolves Flutter `Localizations.of<T>`'s inability to distinguish identical types.
* Provides a global registrar that simplifies `localizationsDelegates` configuration in `MaterialApp`.
