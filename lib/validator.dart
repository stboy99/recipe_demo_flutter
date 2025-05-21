abstract class Validator<t> {
  String? msg(t? value);
}

class DynamicValidator implements Validator<dynamic> {
  final String message;
  DynamicValidator(this.message);

  @override
  String? msg(dynamic value) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }
}