// lib/views/dynamic_form_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:io';

import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/services/render_form_field.dart';
import 'package:zruri/core/services/save_dynamic_form.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_field_types.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_model.dart';

class DynamicFormPage extends StatefulWidget {
  const DynamicFormPage({super.key});

  @override
  State<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  // The selected category is received via arguments and is final
  late final CategoriesModel category;
  late final SaveDynamicForm saveDynamicForm;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State for controllers and focus nodes
  late Map<String, TextEditingController> _controllers;
  late Map<String, FocusNode> _focusNodes;
  final RenderFormField _renderFormField = RenderFormField();

  @override
  void initState() {
    super.initState();

    // 1. Receive the category from arguments
    category = Get.arguments as CategoriesModel;

    // 2. Initialize the controller for saving the form
    saveDynamicForm = Get.put(SaveDynamicForm());

    // 3. Initialize text controllers and focus nodes for the form fields
    _initializeControllersAndFocusNodes();
  }

  void _initializeControllersAndFocusNodes() {
    _controllers = {};
    _focusNodes = {};
    for (final field in category.formFields) {
      if (field.formType == FormTypeValues.text ||
          field.formType == FormTypeValues.multiline ||
          field.formType == FormTypeValues.number) {
        _controllers[field.controlName] = TextEditingController(
          text: field.value,
        );
        _focusNodes[field.controlName] = FocusNode();
      }
    }
    // Update the saveDynamicForm with the fields it will need to save
    saveDynamicForm.formFields.value = category.formFields;
  }

  @override
  void dispose() {
    // Clean up all controllers and focus nodes
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Form Content
            Column(
              children: [
                Expanded(child: _buildFormContent()),
                _buildSubmitButton(),
              ],
            ),

            // Loading Overlay
            Obx(() {
              if (saveDynamicForm.isLoading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.1),
                  child: _buildLoadingState(saveDynamicForm),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'Post Ad in ${category.name}',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildCategoryBanner()),
          _buildFormFieldsSliver(),
          _buildImageSection(saveDynamicForm),
        ],
      ),
    );
  }

  Widget _buildCategoryBanner() {
    // This is much simpler now as the category is guaranteed to exist.
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(category.name),
            _getCategoryColor(category.name).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(category.name).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category.name),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.toString().capitalizeFirst!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Please fill out the details below',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.5, duration: 600.ms).fadeIn();
  }

  Widget _buildFormFieldsSliver() {
    final formFields = category.formFields;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final field = formFields[index];
          final controller = _controllers[field.controlName];
          final focusNode = _focusNodes[field.controlName];

          if (controller != null && focusNode != null) {
            return _renderModernFormField(field, index, controller, focusNode);
          }
          // Handle other field types (dropdown, checkbox) here if they exist
          return const SizedBox.shrink();
        }, childCount: formFields.length),
      ),
    );
  }

  // _renderModernFormField is identical to your original implementation
  Widget _renderModernFormField(
    DynamicModel field,
    int index,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      field.fieldPlaceholder,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (field.isRequired)
                      const Text(' *', style: TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                _renderFormField.renderFormField(
                  field,
                  controller,
                  focusNode,
                  () {}, // No progress update needed
                ),
              ],
            ),
          ),
        )
        .animate()
        .slideX(begin: index.isEven ? -0.3 : 0.3, duration: 500.ms)
        .fadeIn();
  }

  // _buildSubmitButton is identical to your original implementation,
  // just without the PostAdController dependency.
  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitForm, // Always enabled
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.publish_rounded),
                const SizedBox(width: 8),
                Text(
                  'Post Ad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 500.ms);
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (saveDynamicForm.images.isNotEmpty) {
        _formKey.currentState!.save();
        await saveDynamicForm.postAdForm(category.name, category.id);
        _formKey.currentState!.reset();
      } else {
        Get.snackbar(
          'Missing Images',
          'Please add at least one image to your ad',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.image_not_supported, color: Colors.white),
        );
      }
    } else {
      Get.snackbar(
        'Form Incomplete',
        'Please fill in all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    }
  }

  // All other helper methods (_buildImageSection, _pickImages, _buildSelectedImages,
  // _buildLoadingState, _getCategoryIcon, _getCategoryColor) are IDENTICAL to your
  // original ModernPostAdFormPage and can be copied directly into this class.
  // I have omitted them here for brevity but they are required.
  Widget _buildImageSection(SaveDynamicForm saveDynamicForm) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Photos',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${saveDynamicForm.images.length}/10',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add photos to make your ad more attractive',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildImagePicker(saveDynamicForm),
            const SizedBox(height: 16),
            _buildSelectedImages(saveDynamicForm),
          ],
        ),
      ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 400.ms),
    );
  }

  Widget _buildImagePicker(SaveDynamicForm saveDynamicForm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImages(saveDynamicForm),
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('Add Photos'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => saveDynamicForm.images.isNotEmpty
              ? OutlinedButton.icon(
                  onPressed: () => saveDynamicForm.images.clear(),
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _pickImages(SaveDynamicForm saveDynamicForm) async {
    try {
      final List<XFile> images = await ImagePicker().pickMultiImage(
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 80,
      );

      for (XFile file in images) {
        if (saveDynamicForm.images.length < 10) {
          saveDynamicForm.images.add(File(file.path));
        }
      }

      if (images.length > (10 - saveDynamicForm.images.length)) {
        Get.snackbar(
          'Image Limit',
          'You can only add up to 10 images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSelectedImages(SaveDynamicForm saveDynamicForm) {
    return Obx(() {
      if (saveDynamicForm.images.isEmpty) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No images selected',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: saveDynamicForm.images.length,
          itemBuilder: (context, index) {
            final image = saveDynamicForm.images[index];
            return Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => saveDynamicForm.images.removeAt(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(delay: (index * 100).ms, duration: 300.ms);
          },
        ),
      );
    });
  }

  Widget _buildLoadingState(SaveDynamicForm saveDynamicForm) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24, width: Get.width / 2),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  FadeAnimatedText(
                    'Uploading images...',
                    duration: const Duration(seconds: 2),
                  ),
                  FadeAnimatedText(
                    'Processing your ad...',
                    duration: const Duration(seconds: 2),
                  ),
                  FadeAnimatedText(
                    'Almost done!',
                    duration: const Duration(seconds: 2),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 16),
            // Obx(
            //   () => LinearProgressIndicator(
            //     value: saveDynamicForm.uploadProgress.value,
            //     backgroundColor: Colors.grey[200],
            //     valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Jobs & Employment': Icons.work_rounded,
      'Real Estate - For Sale': Icons.home_rounded,
      'Real Estate - For Rent': Icons.apartment_rounded,
      'Vehicles - Cars': Icons.directions_car_rounded,
      'Services': Icons.build_rounded,
      'Electronics': Icons.devices_rounded,
      'Fashion': Icons.checkroom_rounded,
      'Home & Garden': Icons.home_work_rounded,
    };

    return iconMap[categoryName] ?? Icons.category_rounded;
  }

  Color _getCategoryColor(String categoryName) {
    final colorMap = {
      'Jobs & Employment': Colors.blue,
      'Real Estate - For Sale': Colors.green,
      'Real Estate - For Rent': Colors.orange,
      'Vehicles - Cars': Colors.red,
      'Services': Colors.purple,
      'Electronics': Colors.indigo,
      'Fashion': Colors.pink,
      'Home & Garden': Colors.teal,
    };

    return colorMap[categoryName] ?? AppColors.primary;
  }
}
