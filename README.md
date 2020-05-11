# flutter_i18n
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
I18n made easy, for Flutter!

<!-- Badges -->
[![Pub Package](https://img.shields.io/pub/v/flutter_i18n.svg)](https://pub.dev/packages/flutter_i18n)
[![GitHub Actions](https://github.com/ilteoood/flutter_i18n/workflows/Publish%20plugin/badge.svg)](https://github.com/ilteoood/flutter_i18n/actions)

------------------------------------------------



## Why you should use flutter_i18n?

The main goal of *flutter_i18n* is to simplify the i18n process in Flutter.
I would like to recreate the same experience that you have with the Angular i18n: simple *json* files, one for each language that you want to support.


## Loaders

Loader is a class which loads your translations from specific source. 
You can easy override loader and create your own.

Available loaders:

| Class name | Purpose |  
| --- | --- |
| `FileTranslationLoader` |  Loads translation files from JSON or YAML format | 
| `NetworkFileTranslationLoader` | Loads translations from the remote resource | 
| `NamespaceFileTranslationLoader` | Loads translations from separate files |
| `E2EFileTranslationLoader` | Special loader for solving isolates problem with flutter drive |

### `FileTranslationLoader` configuration

To use this library, you must create a folder in your project's root: the `basePath`. Some examples:

> /assets/flutter_i18n (the default one)
>
> /assets/i18n
>
> /assets/locales

Inside this folder, you'll put the *json* or *yaml* files containing the translated keys. You have two options:

- If you want to specify the country code

    > `basePath`/{languageCode}_{countryCode}.json

- otherwise

    > `basePath`/{languageCode}.json

If the *json* file is not available, we will look for a *yaml* file with the same name. In case both exist, the *json* file will be used.

Of course, you must declare the subtree in your ***pubspec.yaml*** as assets:

```yaml
flutter:
  assets:
    - {basePath}
```

The next step consist in the configuration of the *localizationsDelegates*; to use *flutter_i18n*, you should configure as follows:

```dart
localizationsDelegates: [
        FlutterI18nDelegate(translationLoader: FileTranslationLoader(...parameters...)),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
],
```

Below you can find the name and description of the accepted parameters.

The ***useCountryCode*** parameter depends on the *json* configuration:
- if you used the pattern {languageCode}_{countryCode}, ***useCountryCode*** must be **true**
- if you used the pattern {languageCode}, ***useCountryCode*** must be **false**

The ***fallbackFile*** parameter was entroduces with the version **0.1.0** and provide a default language, used when the translation for the current running system is not provided. This should contain the name of a valid *json* file in *assets* folder.

The ***basePath*** parameter is optionally used to set the base path for translations. If this option is not set, the default path will be `assets/flutter_i18n`. This path must be the same path as the one defined in your ***pubspec.yaml***.

The ***forcedLocale*** parameter is optionally used to force a locale instead finding the system one.

The ***decodeStrategies*** parameters is optionally used to choose witch kind of file you want to load. By default JSON, YAML and XML are enabled. If you use only one format, you can speed-up the bootstrap process using only the one you need.

If there isn't any translation available for the required key, even in the fallback file, the same key is returned.

### `NetworkFileTranslationLoader` configuration

Behaviour of this loader very similar as `FileTranslationLoader`. The main difference that we load translations from `NetworkAssetBundle` instead of `CachingAssetBundle`.

Below you can find the name and description of the accepted parameters.

The ***baseUri*** parameter provide base Uri for your remote translations.

The ***useCountryCode*** parameter depends on the *json* configuration:
- if you used the pattern {languageCode}_{countryCode}, ***useCountryCode*** must be **true**
- if you used the pattern {languageCode}, ***useCountryCode*** must be **false**

The ***fallbackFile*** parameter provide a default language, used when the translation for the current running system is not provided.

The ***forcedLocale*** parameter is optionally used to force a locale instead finding the system one.

For example if your translation files located at 
`https://example.com/static/en.json` you should configure as follows:

```dart
localizationsDelegates: [
        FlutterI18nDelegate(translationLoader: 
          NetworkFileTranslationLoader(baseUri: Uri.https("example.com", "static")),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
],
```

### `NamespaceFileTranslationLoader` configuration

Behaviour of this loader very similar as `FileTranslationLoader`. The main difference that we load translations from separate files per each language.

For example `FileTranslationLoader` format:

> /assets/flutter_i18n/en.json
>
> /assets/flutter_i18n/it.json

`NamespaceFileTranslationLoader` format:

> /assets/flutter_i18n/en/home_screen.json
>
> /assets/flutter_i18n/en/about_screen.json
>
> /assets/flutter_i18n/it/home_screen.json
>
> /assets/flutter_i18n/it/about_screen.json

Example configuration:

```dart
localizationsDelegates: [
        FlutterI18nDelegate(translationLoader: 
          NamespaceFileTranslationLoader(namespaces: ["home_screen", "about_screen"]),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
],
```

Below you can find the name and description of the accepted parameters.

The ***namespaces*** provide a list of filenames for the specific language directory.

The ***useCountryCode*** parameter depends on the *json* configuration:
- if you used the pattern {languageCode}_{countryCode}, ***useCountryCode*** must be **true**
- if you used the pattern {languageCode}, ***useCountryCode*** must be **false**

The ***fallbackDir*** provide a default language directory, used when the translation for the current running system is not provided.

The ***basePath*** parameter is optionally used to set the base path for translations. If this option is not set, the default path will be `assets/flutter_i18n`. This path must be the same path as the one defined in your ***pubspec.yaml***.

The ***forcedLocale*** parameter is optionally used to force a locale instead finding the system one.

### `E2EFileTranslationLoader` configuration

The same as `FileTranslationLoader` configuration. This loader can be used for solving problem with flutter drive testing.
It removes using separate isolate for loading translations (detailed issue described here: [issues/24703](https://github.com/flutter/flutter/issues/24703)).

The ***useE2E*** parameter:
- if you are in flutter drive testing mode – must be **true**
- if you are in normal mode – must be **false**, in this case `FileTranslationLoader` will be used

## flutter_i18n in action

After the configuration steps, the only thing to do is invoke the following method:

```dart
FlutterI18n.translate(buildContext, "your.key")
```

Where:
- *buildContext* is the *BuildContext* instance of the widget
- *your.key* is the key to translate

Other examples of use:

Force a language to be loaded at run-time:
```dart
await FlutterI18n.refresh(buildContext, languageCode, {countryCode});
```

Plural translations:
```dart
FlutterI18n.plural(buildContext, "your.key", pluralValue);
```

Text widget shorthand:
```dart
I18nText("your.key", child: Text(""))
I18nText("your.key", translationParams: {"user": "Flutter lover"})
I18nPlural("clicked.times", 1)
I18nPlural("clicked.times", 2, child: Text(""))
```

For more informations and details, read the [CHANGELOG.md](CHANGELOG.md).

Known problems:
    
- In iOS simulator, is always used the *en_US* locale: see [here](https://github.com/ilteoood/flutter_i18n/issues/58).
## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/defint"><img src="https://avatars2.githubusercontent.com/u/1523848?v=4" width="100px;" alt=""/><br /><sub><b>Anton</b></sub></a><br /><a href="#infra-defint" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/ilteoood/flutter_i18n/commits?author=defint" title="Tests">⚠️</a> <a href="https://github.com/ilteoood/flutter_i18n/commits?author=defint" title="Code">💻</a></td>
    <td align="center"><a href="https://lucasvienna.dev"><img src="https://avatars1.githubusercontent.com/u/1761244?v=4" width="100px;" alt=""/><br /><sub><b>Lucas Vienna</b></sub></a><br /><a href="https://github.com/ilteoood/flutter_i18n/commits?author=Avyiel" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!