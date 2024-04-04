import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_validator_types.dart';

class DynamicFormValidator {
  ValidatorTypeValues type;
  String errorMessage;
  int textLength;

  DynamicFormValidator({
    required this.type,
    required this.errorMessage,
    this.textLength = 0,
  });

  DynamicFormValidator.fromJson(dynamic json)
      : type = validatorTypeMap[json['type']] ?? ValidatorTypeValues.novalidate,
        errorMessage = json['error_message'],
        textLength = json['text_length'];
}
