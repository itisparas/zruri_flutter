import 'package:flutter/material.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_field_types.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_model.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_validator_types.dart';

class RenderFormField {
  Widget renderFormField(DynamicModel formField) {
    if (formField.formType == FormTypeValues.text ||
        formField.formType == FormTypeValues.number ||
        formField.formType == FormTypeValues.multiline) {
      return _getTextFormFieldWidget(formField);
    } else {
      return Container();
    }
  }

  TextFormField _getTextFormFieldWidget(DynamicModel formField) {
    return TextFormField(
      decoration: InputDecoration(
        isDense: true,
        hintText: formField.fieldPlaceholder,
      ),
      maxLines: formField.maxLines,
      keyboardType: formField.formType == FormTypeValues.text
          ? TextInputType.text
          : formField.formType == FormTypeValues.multiline
          ? TextInputType.multiline
          : TextInputType.number,
      validator: (value) {
        if (formField.isRequired &&
            formField.validators.any((element) {
              return element.type == ValidatorTypeValues.notempty;
            }) &&
            (value == null || value.isEmpty)) {
          return formField.validators
              .firstWhere(
                (element) => element.type == ValidatorTypeValues.notempty,
              )
              .errorMessage;
        }
        if (formField.validators.any(
          (element) => element.type == ValidatorTypeValues.textLength,
        )) {
          var validator = formField.validators.firstWhere(
            (element) => element.type == ValidatorTypeValues.textLength,
          );
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
