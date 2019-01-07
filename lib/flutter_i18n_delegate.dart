library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final bool _useCountryCode;
  final String _fallbackFile;
  final String _path;

  FlutterI18nDelegate(this._useCountryCode,
      [this._fallbackFile, this._path = "assets/flutter_i18n"]);

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    final FlutterI18n flutterI18n =
        FlutterI18n(_useCountryCode, _fallbackFile, _path);
    await flutterI18n.load();
    return flutterI18n;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return false;
  }
}
