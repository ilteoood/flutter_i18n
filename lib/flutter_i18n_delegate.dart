library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final bool useCountryCode;

  FlutterI18nDelegate(this.useCountryCode);

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    final FlutterI18n flutterI18n = new FlutterI18n(useCountryCode);
    await flutterI18n.load();
    return flutterI18n;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return true;
  }
}
