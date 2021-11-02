import 'package:logging/logging.dart';

/// Used to print console messages with the flutter_i18n prefix
class MessagePrinter {
  static final logger = Logger("flutter_i18n");

  static debug(final String message) {
    logger.fine(message);
  }

  static info(final String message) {
    logger.info(message);
  }

  static error(final String message) {
    logger.shout(message);
  }
}
