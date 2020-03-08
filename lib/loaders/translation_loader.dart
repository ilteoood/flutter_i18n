import 'package:flutter/widgets.dart';

abstract class TranslationLoader {
  Future<Map> load();

  Locale get locale;

  set locale(Locale locale);
}
