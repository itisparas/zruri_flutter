import 'package:zruri/models/dynamic-form-models/dynamic_form_field_list_items.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_field_types.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_validator.dart';

class DynamicModel {
  String controlName;
  FormTypeValues formType;
  String fieldPlaceholder;
  String value;
  bool isRequired;
  List<DynamicFormValidator> validators;
  int maxLines;
  List<ItemModel>? items;
  ItemModel? selectedItem;

  DynamicModel(
    this.controlName,
    this.formType,
    this.fieldPlaceholder,
    this.value, {
    this.isRequired = false,
    this.validators = const [],
    this.maxLines = 1,
    this.items,
    this.selectedItem,
  });

  DynamicModel.fromJson(dynamic json)
    : controlName = json['controlName'],
      formType = formTypeMap[json['formType']] ?? FormTypeValues.text,
      fieldPlaceholder = json['fieldPlaceholder'],
      value = json['value'] ?? '',
      isRequired = json['isRequired'],
      validators = (json['validators'] as List<dynamic>)
          .map((e) => DynamicFormValidator.fromJson(e))
          .toList(),
      maxLines = json['maxLines'],
      items = json['items'] != null
          ? (json['items'] as List<dynamic>)
                .map((item) => ItemModel.fromJson(item))
                .toList()
          : [],
      selectedItem = json['selectedItem'] != null
          ? ItemModel.fromJson(json['selectedItem'])
          : null;
}
