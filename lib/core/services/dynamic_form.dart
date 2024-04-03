import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FormType { text, multiline, dropdown, autoComplete, datePicker }

enum ValidatorType { notEmpty, textLength, phoneNumber, age, email }

class ItemModel {
  int id;
  int parentId;
  String name;
  ItemModel(
    this.id,
    this.name, {
    this.parentId = 0,
  });
}

class DynamicFormValidator {
  ValidatorType type;
  String errorMessage;
  int textLength;
  DynamicFormValidator(
    this.type,
    this.errorMessage, {
    this.textLength = 0,
  });
}

class DynamicModel {
  String controlName;
  FormType formType;
  String value;
  List<ItemModel> items;
  ItemModel? selectedItem;
  bool isRequired;
  List<DynamicFormValidator> validators;
  DynamicModel(
    this.controlName,
    this.formType,
    this.value, {
    this.items = const [],
    this.selectedItem,
    this.isRequired = false,
    this.validators = const [],
  });
}

class DynamicForm extends GetxService {
  TextFormField getTextWidget(index) {
    return TextFormField(
      decoration: const InputDecoration(),
    );
  }
}
