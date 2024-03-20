class AppMessages {
  static const Map<String, dynamic> enUs = {
    'app.title': "Flutter Demo",
    'snackbar': {
      'error.title': 'Errr!',
      'success.title': 'Yayy!',
      'auth': {
        'error': {
          'otpSendFailed':
              'Error while sending verification code, please try again.',
          'incorrectOtp': 'Incorrect verification code/otp.',
          'logout':
              'There was some issue while logging out. Please try again or contact us.',
          'updateDisplayName':
              'There was some issue while updating user name. Please try again or contact us.',
        },
        'success': {
          'otpSent':
              'Verification code/otp has been sent to your mobile number.',
          'login': 'Logged in successfully.',
          'logout': "Logged out successfully. We'll miss you, come back soon.",
          'updateDisplayName': 'User name updated successfully.',
        }
      }
    }
  };
}
