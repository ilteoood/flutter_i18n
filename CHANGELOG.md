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