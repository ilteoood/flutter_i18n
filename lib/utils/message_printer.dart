/// Used to print console messages with the flutter_i18n prefix
class MessagePrinter {
  static bool _mustPrintMessage;

  static setMustPrintMessage(bool mustPrintMessage) =>
      _mustPrintMessage = mustPrintMessage;

  static debug(final String message) {
    _printMessage("DEBUG", message);
  }

  static info(final String message) {
    _printMessage("INFO", message);
  }

  static error(final String message) {
    _printMessage("ERROR", message);
  }

  static _printMessage(final String prefix, final String message) {
    if (_mustPrintMessage) {
      print("[flutter_i18n $prefix]: $message");
    }
  }
}
