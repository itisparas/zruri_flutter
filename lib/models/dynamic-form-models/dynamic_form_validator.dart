import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_validator_types.dart';

class DynamicFormValidator {
  ValidatorTypeValues type = ValidatorTypeValues.novalidate;
  String errorMessage = '';
  int textLength = 255;

  DynamicFormValidator(
    this.type,
    this.errorMessage,
    this.textLength,
  );

  DynamicFormValidator.fromJson(dynamic json)
      : type = validatorTypeMap[json['type']] ?? ValidatorTypeValues.novalidate,
        errorMessage = json['error_message'],
        textLength = json['text_length'];
}
