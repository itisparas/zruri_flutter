import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/constants.dart';

class AppDefaults {
  static const double radius = 4;
  static const double margin = 15;
  static const double padding = 15;
  static const double inputRadius = 4;

  static BorderRadius borderRadius = BorderRadius.circular(radius);

  static double otpPinFieldWidth = Get.width / 7;
  static double otpPinFieldHeight = otpPinFieldWidth;
  static BoxDecoration otpPinFieldDefaultDecoration = BoxDecoration(
    border: Border.all(
      color: AppColors.primary,
    ),
    borderRadius: borderRadius,
  );
  static BoxDecoration otpPinFieldFocusedDecoration = BoxDecoration(
    border: Border.all(
      color: AppColors.primary,
      width: 2,
    ),
    borderRadius: borderRadius,
  );

  static BorderRadius bottomSheetBorderRadius = const BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );

  static BorderRadius topSheetBorderRadius = const BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );

  static List<BoxShadow> boxShadow = [
    BoxShadow(
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 2),
        color: Colors.black.withOpacity(0.04))
  ];

  static Duration duration = const Duration(milliseconds: 300);

  static String? fontFamily = GoogleFonts.ibmPlexSans().fontFamily;

  // Constants for the GetX snackbar
  static SnackPosition snackPosition = SnackPosition.BOTTOM;
  static Color snackbarBackgroundColor = Colors.black;
  static Color snackbarColorText = Colors.white;
  static Duration snackbarDuration = const Duration(seconds: 5);
  static bool isSnackbarDismissible = false;

  // Constants for defining outline of inputs
  static const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 0.1),
    borderRadius: BorderRadius.all(Radius.circular(inputRadius)),
  );
  static OutlineInputBorder outlineOtpInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(width: 0.1),
    borderRadius: BorderRadius.circular(radius),
  );

  // Constants for decorating different input fields
  static InputDecorationTheme inputDecorationTheme = const InputDecorationTheme(
    fillColor: AppColors.textInputBackground,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    suffixIconColor: AppColors.placeholder,
  );
  static InputDecorationTheme secondaryInputDecorationTheme =
      const InputDecorationTheme(
    fillColor: AppColors.textInputBackground,
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(inputRadius)),
    ),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
  );
  static InputDecorationTheme otpInputDecorationTheme = InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: outlineOtpInputBorder,
    enabledBorder: outlineOtpInputBorder,
    focusedBorder: outlineOtpInputBorder,
  );
}
