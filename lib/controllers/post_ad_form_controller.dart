import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/core/services/save_dynamic_form.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_field_types.dart';

class PostAdFormController extends GetxController {
  static PostAdFormController get instance => Get.find();

  final Rx<CategoriesModel?> selectedCategory = Rx<CategoriesModel?>(null);
  final RxDouble formProgress = 0.0.obs;

  void selectCategory(CategoriesModel category) {
    // 3. Set the new category.
    selectedCategory.value = category;

    // 5. Recalculate the form progress.
    updateFormProgress();
  }

  void clearCategory() {
    selectedCategory.value = null;
    formProgress.value = 0.0;
  }

  // KEY CHANGE: Accept the controllers map to perform an accurate calculation.
  void updateFormProgress({Map<String, TextEditingController>? controllers}) {
    if (selectedCategory.value == null) {
      formProgress.value = 0.0;
      return;
    }

    // Base progress for having a category selected
    double categoryProgress = 0.2;

    // Form fields progress (60% of total)
    double formFieldsProgress = 0.0;
    if (controllers != null && selectedCategory.value!.formFields.isNotEmpty) {
      // Count only required fields for progress calculation
      final requiredFields = selectedCategory.value!.formFields
          .where((f) => f.isRequired)
          .toList();
      if (requiredFields.isNotEmpty) {
        int filledRequiredFields = 0;
        for (final field in requiredFields) {
          if (controllers.containsKey(field.controlName) &&
              controllers[field.controlName]!.text.isNotEmpty) {
            filledRequiredFields++;
          }
        }
        formFieldsProgress =
            (filledRequiredFields / requiredFields.length) * 0.6;
      }
    }

    // Images progress (20% of total)
    double imageProgress = Get.find<SaveDynamicForm>().images.isNotEmpty
        ? 0.2
        : 0.0;

    // Combine all progress parts
    formProgress.value = categoryProgress + formFieldsProgress + imageProgress;
  }
}
