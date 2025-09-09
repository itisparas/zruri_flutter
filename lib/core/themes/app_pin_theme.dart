import 'package:pinput/pinput.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/constants/constants.dart';

class AppPinTheme {
  static PinTheme defaultPinTheme = PinTheme(
    height: AppDefaults.otpPinFieldHeight,
    width: AppDefaults.otpPinFieldWidth,
    decoration: AppDefaults.otpPinFieldDefaultDecoration,
  );

  static PinTheme focusedPinTheme = defaultPinTheme.copyWith(
    decoration: AppDefaults.otpPinFieldFocusedDecoration,
  );
}
