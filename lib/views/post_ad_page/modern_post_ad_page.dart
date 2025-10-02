// lib/views/post_ad_form_page/modern_post_ad_form_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:io';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/controllers/post_ad_form_controller.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/services/render_form_field.dart';
import 'package:zruri/core/services/save_dynamic_form.dart';
import 'package:zruri/models/categories_model.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_field_types.dart';
import 'package:zruri/models/dynamic-form-models/dynamic_form_model.dart';

class ModernPostAdFormPage extends StatefulWidget {
  const ModernPostAdFormPage({super.key});

  @override
  State<ModernPostAdFormPage> createState() => _ModernPostAdFormPageState();
}

class _ModernPostAdFormPageState extends State<ModernPostAdFormPage> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Declare controllers here
  late final PostAdFormController postAdController;
  late final CategoriesController categoriesController;
  late final SaveDynamicForm saveDynamicForm;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    postAdController = Get.put(PostAdFormController());
    categoriesController = Get.put(CategoriesController());
    saveDynamicForm = Get.put(SaveDynamicForm());
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    postAdController.dispose();
    categoriesController.dispose();
    saveDynamicForm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context, postAdController),
      body: SafeArea(
        // KEY CHANGE: Use a Stack to overlay the loading indicator.
        child: Stack(
          children: [
            // The main content is now the FIRST layer of the Stack.
            // It is NOT wrapped in an Obx and will NOT be rebuilt.
            Column(
              children: [
                _buildCurrencyBanner(),
                Expanded(
                  child: _buildFormContent(
                    categoriesController,
                    postAdController,
                    saveDynamicForm,
                  ),
                ),
                _buildSubmitButton(postAdController, saveDynamicForm),
              ],
            ),

            // The loading indicator is the SECOND layer, controlled by Obx.
            // This Obx now ONLY controls the loading widget's visibility.
            Obx(() {
              if (saveDynamicForm.isLoading.value) {
                // We add a semi-transparent background to block interaction with the form.
                return Container(
                  color: Colors.black.withOpacity(0.1),
                  child: _buildLoadingState(saveDynamicForm),
                );
              } else {
                // When not loading, return an empty container.
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    PostAdFormController controller,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Post Your Ad',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Obx(() {
          return LinearProgressIndicator(
            value: controller.formProgress.value,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          );
        }),
      ),
    );
  }

  Widget _buildCurrencyBanner() {
    final PostAdFormController postAdController =
        Get.find<PostAdFormController>();

    return Obx(() {
      final selectedCategory = postAdController.selectedCategory.value;

      if (selectedCategory != null) {
        // Show selected category banner
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(selectedCategory.name),
                _getCategoryColor(selectedCategory.name),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getCategoryColor(
                  selectedCategory.name,
                ).withOpacity(0.3),
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
                  _getCategoryIcon(selectedCategory.name),
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
                      selectedCategory.name.toString().capitalizeFirst!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Category selected',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  postAdController.selectedCategory.value = null;
                  postAdController.formProgress.value = 0.0;
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: -0.5, duration: 600.ms).fadeIn();
      } else {
        // Show original currency banner
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
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
                child: const Text('🇨🇦', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posting in Canada',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'All prices in Canadian Dollars (CAD)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CAD',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: -0.5, duration: 600.ms).fadeIn();
      }
    });
  }

  Widget _buildFormContent(
    CategoriesController categoriesController,
    PostAdFormController postAdController,
    SaveDynamicForm saveDynamicForm,
  ) {
    // KEY CHANGE: The Obx wrapper is GONE.
    // We will handle the initial loading state differently if needed,
    // but for now, this is much more stable.
    return Form(
      key: _formKey,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildCategorySelectionSection(
            categoriesController,
            postAdController,
          ),

          // This inner Obx is fine and is now the ONLY thing rebuilding
          // this part of the sliver list.
          Obx(() {
            final selectedCategory = postAdController.selectedCategory.value;
            if (selectedCategory == null) {
              return _buildSelectCategoryPlaceholder();
            } else {
              // Your existing DynamicFormSliver
              return DynamicFormSliver(
                key: ValueKey(selectedCategory.id),
                category: selectedCategory,
                postAdController: postAdController,
                saveDynamicForm: saveDynamicForm,
              );
            }
          }),

          _buildImageSection(saveDynamicForm),
        ],
      ),
    );
  }

  Widget _buildSelectCategoryPlaceholder() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.arrow_upward_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select a Category First',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionSection(
    CategoriesController categoriesController,
    PostAdFormController postAdController,
  ) {
    return Obx(() {
      // Hide category selection if category is already selected
      if (postAdController.selectedCategory.value != null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Category',
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
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the category that best describes your item',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(categoriesController, postAdController),
            ],
          ),
        ).animate().slideX(begin: -0.3, duration: 500.ms).fadeIn(),
      );
    });
  }

  Widget _buildCategoryDropdown(
    CategoriesController categoriesController,
    PostAdFormController postAdController,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<CategoriesModel>(
        value: postAdController.selectedCategory.value,
        decoration: const InputDecoration(
          hintText: 'Choose a category...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          prefixIcon: Icon(Icons.category_outlined),
        ),
        isExpanded: true,
        items: categoriesController.categories.map((category) {
          return DropdownMenuItem<CategoriesModel>(
            value: category,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    size: 18,
                    color: _getCategoryColor(category.name),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name.toString().capitalizeFirst!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (category.homepage)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (CategoriesModel? category) {
          if (category != null) {
            postAdController.selectCategory(category);
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

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

  Widget _buildSubmitButton(
    PostAdFormController postAdController,
    SaveDynamicForm saveDynamicForm,
  ) {
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
          child: Obx(
            () => ElevatedButton(
              onPressed: postAdController.selectedCategory.value != null
                  ? () => _submitForm(postAdController, saveDynamicForm)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    postAdController.selectedCategory.value != null
                        ? Icons.publish_rounded
                        : Icons.category_rounded,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    postAdController.selectedCategory.value != null
                        ? 'Post Ad'
                        : 'Select Category First',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 500.ms);
  }

  void _submitForm(
    PostAdFormController postAdController,
    SaveDynamicForm saveDynamicForm,
  ) {
    if (_formKey.currentState?.validate() ?? false) {
      if (saveDynamicForm.images.isNotEmpty) {
        _formKey.currentState!.save();
        saveDynamicForm.postAdForm(
          postAdController.selectedCategory.value!.name,
          postAdController.selectedCategory.value!.id,
        );
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
            const SizedBox(height: 24),
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

class DynamicFormSliver extends StatefulWidget {
  final CategoriesModel category;
  final PostAdFormController postAdController;
  final SaveDynamicForm saveDynamicForm;

  const DynamicFormSliver({
    super.key,
    required this.category,
    required this.postAdController,
    required this.saveDynamicForm,
  });

  @override
  State<DynamicFormSliver> createState() => _DynamicFormSliverState();
}

class _DynamicFormSliverState extends State<DynamicFormSliver> {
  // The state of this widget holds the controllers!
  late Map<String, TextEditingController> _controllers;
  late Map<String, FocusNode> _focusNodes;
  final RenderFormField _renderFormField = RenderFormField();

  @override
  void initState() {
    super.initState();
    // Create controllers when the widget is first created.
    _initializeControllersAndFocusNodes();
  }

  void _initializeControllersAndFocusNodes() {
    _controllers = {};
    _focusNodes = {};
    for (final field in widget.category.formFields) {
      if (field.formType == FormTypeValues.text ||
          field.formType == FormTypeValues.multiline ||
          field.formType == FormTypeValues.number) {
        _controllers[field.controlName] = TextEditingController(
          text: field.value,
        );
        _controllers[field.controlName]!.addListener(_onFieldValueChanged);
      }
    }
    // Update the saveDynamicForm with the fields
    widget.saveDynamicForm.formFields.value = widget.category.formFields;
  }

  @override
  void didUpdateWidget(covariant DynamicFormSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the category changes, we need to dispose old controllers and create new ones.
    if (widget.category.id != oldWidget.category.id) {
      _disposeAll();
      _initializeControllersAndFocusNodes();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed from the tree.
    _disposeAll();
    super.dispose();
  }

  void _disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.removeListener(() {});
      focusNode.dispose();
    }
  }

  void _onFieldValueChanged() {
    // This is the callback for when a user types in a field.
    // You can make this progress calculation more detailed if needed.
    widget.postAdController.updateFormProgress(controllers: _controllers);
  }

  @override
  Widget build(BuildContext context) {
    final formFields = widget.category.formFields;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final field = formFields[index];
          final controller = _controllers[field.controlName];
          final focusNode = _focusNodes[field.controlName];

          // If it's a field that needs a controller, build it.
          if (controller != null && focusNode != null) {
            return _renderModernFormField(field, index, controller, focusNode);
          }

          // Otherwise, return an empty container or another field type.
          return const SizedBox.shrink();
        }, childCount: formFields.length),
      ),
    );
  }

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
                  _onFieldValueChanged,
                ),
              ],
            ),
          ),
        )
        .animate()
        .slideX(begin: index.isEven ? -0.3 : 0.3, duration: 500.ms)
        .fadeIn();
  }
}
