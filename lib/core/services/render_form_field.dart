import 'package:flutter/material.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_model.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_validator_types.dart';

class RenderFormField {
  TextFormField getTextFormFieldWidget(DynamicModel formField) {
    return TextFormField(
      decoration: InputDecoration(
        isDense: true,
        hintText: formField.fieldPlaceholder,
      ),
      maxLines: formField.maxLines,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (formField.isRequired &&
            formField.validators.any(
                (element) => element.type == ValidatorTypeValues.notEmpty) &&
            (value == null || value.isEmpty)) {
          return formField.validators
              .firstWhere(
                  (element) => element.type == ValidatorTypeValues.notEmpty)
              .errorMessage;
        }
        if (formField.validators
            .any((element) => element.type == ValidatorTypeValues.textLength)) {
          var validator = formField.validators.firstWhere(
              (element) => element.type == ValidatorTypeValues.textLength);
          int? len = value?.length;
          if (len != null && len > validator.textLength) {
            return validator.errorMessage;
          }
        }
        return null;
      },
      onChanged: (value) => formField.value = value,
    );
  }
}
