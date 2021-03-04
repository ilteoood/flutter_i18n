import 'package:flutter_i18n/utils/message_printer.dart';

import 'actions/ActionInterface.dart';
import 'actions/DiffAction.dart';
import 'actions/ValidateAction.dart';

void main(final List<String> args) async {
  validateLength(args);
  final AbstractAction actionInterface = retrieveAction(args[0]);
  MessagePrinter.setMustPrintMessage(true);
  actionInterface.executeAction(args.sublist(1));
}

void validateLength(final List<String> args) {
  if (args.length == 0) {
    throw new Exception("Empty list of args");
  }
}

AbstractAction retrieveAction(final String action) {
  switch (action) {
    case 'validate':
      return ValidateAction();
    case 'diff':
      return DiffAction();
    default:
      throw new Exception("Unrecognized arg: $action");
  }
}
