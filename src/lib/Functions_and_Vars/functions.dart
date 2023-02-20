import 'package:email_validator/email_validator.dart';
import 'package:string_validator/string_validator.dart';

// Validator class for emails and passwords and other input
class Validators {
  static String? emailValidator(input) {
    if (!EmailValidator.validate(input)) {
      return 'Invalid Email Address';
    }
    return null;
  }

  static String? passwordValidator(input) {
    if (input == null || input.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  static String? ageValidator(input) {
    if (input == null || input.isEmpty || !isNumeric(input)) {
      return 'Enter valid Age';
    }
    return null;
  }

  static String? otherValidator(input) {
    if (input == null || input.isEmpty) {
      return 'Enter valid input';
    }
    return null;
  }

  // for add and edit resource page
  static String? ageInputValidator(input) {
    if (input == null || input.isEmpty) {
      return 'Empty. Enter a valid input';
    }

    String lowerCaseInput = input!.toLowerCase();
    if (lowerCaseInput == "all") {
      return null;
    } else {
      RegExp exp = RegExp(r"^(\d+-\d+)$");
      if (!exp.hasMatch(input)) {
        return 'Enter one age range separated by a dash. E.g 1-21.\nOr if all ages are served enter ALL';
      }
      return null;
    }
  }

  static String? inputValidator(input) {
    if (input != "" || input.isNotEmpty) {
      RegExp exp = RegExp(r"^(\w+)+(,\w+)*$");
      if (!exp.hasMatch(input)) {
        return 'Enter the items separated by a comma with no spaces\nE.g NH,VT';
      } else {
        return null;
      }
    }
    return null;
  }
}
