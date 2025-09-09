class AppMessages {
  static const Map<String, dynamic> enUs = {
    'app.title': "Zruri",
    'postingpage.title': 'Post your ad',
    'postingpage.choosecategory': 'Choose your category',
    "prompt.location.title": "Hey buddy! \n Where are you located?",
    'prompt.location.description':
        'To provide the relevant services/products we need to know your location.',
    'categoriespage.title': 'Categories',
    'modal': {
      'confirm.delete': {
        'title': 'Confirm delete?',
        'description': 'Are you sure you want to delete your\'s ad post?'
      },
      'confirm.deactivate': {
        'title': 'Deactivate ad?',
        'description': 'Are you sure you want to deactivate your\'s ad post?'
      },
      'confirm.activate': {
        'title': 'Publish ad?',
        'description': 'Are you sure you want to publish this ad post?'
      }
    },
    'snackbar': {
      'error.title': 'Errr!',
      'success.title': 'Yayy!',
      'error.imageupload': 'oh no! image upload failed.\nPlease try again.',
      'error.imagenotuploaded': 'oh no! please upload atleast one image.',
      'error.invalidform': 'oh no! please re-validate the form.',
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
