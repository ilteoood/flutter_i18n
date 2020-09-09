class MessagePrinter {
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
    print("[flutter_i18n $prefix]: $message");
  }
}
