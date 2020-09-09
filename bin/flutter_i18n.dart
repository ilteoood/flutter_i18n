import 'actions/ActionInterface.dart';
import 'actions/DiffAction.dart';
import 'actions/ValidateAction.dart';

void main(final List<String> args) async {
  validateLength(args);
  validateArg(args[0]);
  final ActionInterface actionInterface = retrieveAction(args[0]);
  actionInterface.executeAction(args.sublist(1));
}

void validateLength(final List<String> args) {
  if(args.length == 0) {
    throw new Exception("Empty list of args");
  }
}

void validateArg(final String action) {
  final List<String> allowedArgs = ['validate', 'diff'];
  final bool argsValid = allowedArgs.contains(action);
  if (!argsValid) {
    throw new Exception("Unrecognized arg: $action");
  }
}

ActionInterface retrieveAction(final String action) {
  switch (action) {
    case 'validate':
      return ValidateAction();
    case 'diff':
      return DiffAction();
  }
}
