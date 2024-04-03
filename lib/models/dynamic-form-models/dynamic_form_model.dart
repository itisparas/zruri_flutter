import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_field_list_items.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_field_types.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_validator.dart';

class DynamicModel {
  String controlName;
  FormTypeValues formType;
  String value;
  List<ItemModel>? items;
  ItemModel? selectedItem;
  bool isRequired;
  List<DynamicFormValidator> validators;

  DynamicModel(
    this.controlName,
    this.formType,
    this.value, {
    this.items,
    this.selectedItem,
    this.isRequired = false,
    this.validators = const [],
  });

  DynamicModel.fromJson(dynamic json)
      : controlName = json['controlName'],
        formType = formTypeMap[json['formType']] ?? FormTypeValues.text,
        value = json['value'] ?? '',
        items = json['items'] != null
            ? (json['items'] as List<dynamic>)
                .map((item) => ItemModel.fromJson(item))
                .toList()
            : [],
        selectedItem = json['selectedItem'] != null
            ? ItemModel.fromJson(json['selectedItem'])
            : null,
        isRequired = json['isRequired'],
        validators = (json['validators'] as List<dynamic>)
            .map((e) => DynamicFormValidator.fromJson(e))
            .toList();
}
