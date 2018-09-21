library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final bool _useCountryCode;
  final String _fallbackFile;

  FlutterI18nDelegate(this._useCountryCode, [this._fallbackFile]);

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    final FlutterI18n flutterI18n = FlutterI18n(_useCountryCode, _fallbackFile);
    await flutterI18n.load();
    return flutterI18n;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return true;
  }
}
