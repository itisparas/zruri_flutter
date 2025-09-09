import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_model.dart';

class CategoriesModel {
  String id;
  bool homepage;
  String name;
  List<DynamicModel> formFields;

  CategoriesModel({
    required this.id,
    required this.homepage,
    required this.name,
    this.formFields = const [],
  });

  CategoriesModel.fromDocumentSnapshot(DocumentSnapshot snapshot)
    : id = snapshot.id,
      homepage = snapshot['homepage'] ?? false,
      formFields = (snapshot['form_fields'] as List<dynamic>)
          .map((e) => DynamicModel.fromJson(e))
          .toList(),
      name = snapshot['name'];
}
