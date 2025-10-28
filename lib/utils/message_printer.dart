import 'package:logging/logging.dart';

/// Used to print console messages with the flutter_i18n prefix
class MessagePrinter {
  static final logger = Logger("flutter_i18n");

  static void debug(final String message) {
    logger.fine(message);
  }

  static void info(final String message) {
    logger.info(message);
  }

  static void error(final String message) {
    logger.shout(message);
  }
}
