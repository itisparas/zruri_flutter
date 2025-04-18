import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/views/onboarding/components/onboarding_view.dart';
import 'package:zruri_flutter/views/onboarding/data/onboarding_data.dart';
import 'package:zruri_flutter/views/onboarding/data/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentPage = 0;
  late PageController controller;
  List<OnboardingModel> items = OnboardingData.items;

  onPageChange(int value) {
    currentPage = value;
    setState(() {});
  }

  _gotoNextPage() {
    if (currentPage < items.length - 1) {
      controller.nextPage(duration: AppDefaults.duration, curve: Curves.ease);
    } else {
      _gotoAuthPage();
    }
  }

  _gotoAuthPage() => Get.offAllNamed('/login');

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: PageView.builder(
                onPageChanged: onPageChange,
                itemCount: items.length,
                controller: controller,
                itemBuilder: (context, index) {
                  return OnboardingView(data: items[index]);
                },
              ),
            ),
            const Spacer(),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(
                      begin: 0, end: (1 / items.length) * (currentPage + 1)),
                  duration: AppDefaults.duration,
                  curve: Curves.easeInOutBack,
                  builder: (context, double value, _) => SizedBox(
                    height: 70,
                    width: 70,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor: AppColors.cardColor,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _gotoNextPage,
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  child: const Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }
}
