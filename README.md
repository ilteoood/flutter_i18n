# flutter_i18n
I18n made easy, for Flutter!

------------------------------------------------



## Why you should use flutter_i18n?

The main goal of *flutter_i18n* is to simplify the i18n process in Flutter.
I would like to recreate the same experience that you have with the Angular i18n: simple *json* files, one for each language that you want to support.



## Configuration

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

```sh
flutter:
  assets:
    - {basePath}
```

The next step consist in the configuration of the *localizationsDelegates*; to use *flutter_i18n*, you should configure as follows:

```sh
localizationsDelegates: [
        FlutterI18nDelegate(...parameters...),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
],
```

Below you can find the name and description of the accepted parameters.

The ***useCountryCode*** parameter depends on the *json* configuration:
- if you used the pattern {languageCode}_{countryCode}, ***useCountryCode*** must be **true**
- if you used the pattern {languageCode}, ***useCountryCode*** must be **false**

The ***fallbackFile*** parameter was entroduces with the version **0.1.0** and provide a default language, used when the translation for the current running system is not provided. This should contain the name of a valid *json* file in *assets* folder.

The ***path*** parameter is optionally used to set the base path for translations. If this option is not set, the default path will be `assets/flutter_i18n`. This path must be the same path as the one defined in your ***pubspec.yaml***.

The ***forcedLocale*** parameter is optionally used to force a locale instead finding the system one.

If there isn't any translation available for the required key, the same key is returned.

## flutter_i18n in action

After the configuration steps, the only thing to do is invoke the following method:

```sh
FlutterI18n.translate(buildContext, "your.key")
```

Where:
- *buildContext* is the *BuildContext* instance of the widget
- *your.key* is the key to translate

Other examples of use:

Force a language to be loaded at run-time:
```sh
await FlutterI18n.refresh(buildContext, languageCode, {countryCode});
```

Plural translations:
```sh
FlutterI18n.plural(buildContext, "your.key", pluralValue);
```


For more informations and details, read the [CHANGELOG.md](CHANGELOG.md).

Known problems:
    
- In iOS simulator, is always used the *en_US* locale: see [here](https://github.com/ilteoood/flutter_i18n/issues/58).