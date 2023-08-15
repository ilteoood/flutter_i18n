## [0.2.0]

*flutter_i18n* now manage strings that contain parameters; an example can be: "Hello, {user}!"
For a correct translation, you must use the third parameter of the *translate* method, a *Map<String, String>* where:
- the keys are the placeholders used in the *.json* file (i.e. user)
- the values are what you want to display

## [0.3.0]

*flutter_i18n* now supports language change at runtime. To use it, you ***must*** invoke the method
```sh
await FlutterI18n.refresh(buildContext, languageCode, {countryCode});
```

***NOTE***: *countryCode* is optional.

## [0.4.0]

*flutter_i18n* now supports plurals. To use it, invoke the method:
```sh
FlutterI18n.plural(buildContext, "your.key", pluralValue);
```

Where pluralValue is the integer value that will be used to determinate the plural form of the translation.

Here is an example of configuration of the *.json* file:

```sh
"clicked": {
    "times-0": "You clicked {times} times!",
    "times-1": "You clicked {time} time!",
    "times-2": "You clicked {times} times!"
  }
```

With this configuration, you must invoke the *plural* method as follow:

```sh
FlutterI18n.plural(buildContext, "clicked.times", pluralValue);
```

FlutterI18n will choose the right key using the value of pluralValue: it will match the last key with a value <= of pluralValue.


## [0.5.0]

*flutter_i18n* now supports the `basePath` configuration.
The default one is: `assets/flutter_i18n`.
To configure it, use the third optional parameter of `FlutterI18nDelegate`.

## [0.5.1]

Print in log when a key is not found.

## [0.5.2]

Fix for bug #10.

## [0.6.0]

Exposed new method that return the locale used by the library, as requested in #16:

```sh
FlutterI18n.currentLocale();
```

***NOTE***: the ***refresh*** method now accept a *Locale* as second parameter, instead of two strings.
***NOTE***: the constructor of *FlutterI18nDelegate* now accept only named parameter.

## [0.6.1]

Fix for bug #22

## [0.6.2]

Fix for the delegate

## [0.6.3]

Fix for #17

## [0.6.4]

Fix for #41

## [0.7.0]

Fix for #48 and implemented feature for #49.
From this version of *FlutterI18n*, you can use as 4th parameter the ***forcedLanguage*** parameter, in order to avoid to call the *refresh* method on application startup.

## [0.8.0]

Support for *yml* language files

## [0.8.1]

Improved *json* and *yml* loading

## [0.8.2]

Bugfix and code improvement

## [0.8.3]

Library will print debug messages only in development mode

## [0.9.0]

Added a new optional parameter to the translate method: *fallbackKey*.
You can use it when the translation *key* is not found.

## [0.10.0]

Added stateless widgets in order to avoid to deal with BuildContext.
```dart
I18nText("your.key", Text(""))
I18nText("your.key", Text(""), translationParams: {"user": "Flutter lover"})
I18nPlural("clicked.times", 2, Text(""))
```

## [0.11.0]

New translation mechanism, with different and customizable loaders provided:

* FileTranslationLoader
* NetworkFileTranslationLoader
* E2EFileTranslationLoader

## [0.11.1]

Plural translator improvements

## [0.12.0]

New loader provided: ```NamespaceFileTranslationLoader```

## [0.13.0]

In the I18nText and I18nPlural widgets, the child parameter is now optional.
The default value of the child parameter is now ```Text("")```

## [0.13.1]

Fix for #83.

## [0.13.2]

Fixed immutable warnings.

## [0.14.0]

New feature: file translation decode strategies.
New translation strategy provided, able to load XML file.

## [0.15.0]

New feature: missing key are now retrieved from the fallback file.

## [0.16.0]

Full support for supportedLocales

## [0.16.1]

Support for decode strategies on other loaders

## [0.16.2]

Added missing translation handler, according to [issue/67](https://github.com/ilteoood/flutter_i18n/issues/67)

## [0.16.3]

Removed cache parameter from loadString method, resolve [issue/116](https://github.com/ilteoood/flutter_i18n/issues/116)

## [0.17.0]

RTL support.
Test fix for [issue/115](https://github.com/ilteoood/flutter_i18n/issues/115)

## [0.18.0]

New loader provided:

* LocalTranslationLoader

## [0.19.0]

Support for Flutter Web.
Note: due to dart:io bug, NetworkFileTranslationLoader can't be used.

## [0.19.1]

Removed useless parameter from LocalTranslationLoader and fixed delegate load method.

## [0.19.2]

Plugins and better Flutter Web support.

## [0.19.3]

Removed dart:io for better Flutter Web support.

## [0.19.4]

Better dartdocs

## [0.20.0]

Loading and loaded stream, in order to detect loading translations status

## [0.20.1]

Fix for streams listened twice

## [0.21.0]

Introducing validate and diff actions

## [0.21.1]

Fix for #150

## [0.22.0]

Initial Flutter 2 support:
- intl upgraded to version 0.17.0
- example app upgraded to Android X
- null safe migration

## [0.22.1]

Nullsafe support + static analysis fixes

## [0.22.2]

Dartfmt

## [0.22.3]

Fix for #159

## [0.22.4]

Fix for #167
Dependencies upgrade

## [0.30.0]

Support for script code
Support for toml format
Fix for #173

## [0.31.0]
Fix for #179

## [0.31.1]
Fix for #184

## [0.32.0]
Fix for #186
Recursively merge the translation map with the fallback map

## [0.32.1]
Fix for #189

## [0.32.2]
Fix for #190

## [0.32.3]
Fix for #197 and #196

## [0.32.4]
Dependencies upgrade

## [0.32.5]
Dependencies upgrade

## [0.33.0]
Support for Dart 3 and Flutter 3.10
Fix for #204

## [0.34.0]
Upgrade http@1.1.0, logging@1.2.0, xml2json@6.2.0, yaml@3.1.2, path@1.8.3
Fix: deprecation warnings