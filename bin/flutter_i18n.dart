import 'actions/action_interface.dart';
import 'actions/diff_action.dart';
import 'actions/validate_action.dart';

void main(final List<String> args) async {
  validateLength(args);
  final AbstractAction actionInterface = retrieveAction(args[0]);
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
