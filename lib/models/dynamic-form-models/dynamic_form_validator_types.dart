enum ValidatorTypeValues {
  novalidate,
  notempty,
  textLength,
  phoneNumber,
  age,
  email
}

final Map<String, ValidatorTypeValues> validatorTypeMap = {
  'novalidate': ValidatorTypeValues.novalidate,
  'notempty': ValidatorTypeValues.notempty,
  'textlength': ValidatorTypeValues.textLength,
  'phonenumber': ValidatorTypeValues.phoneNumber,
  'age': ValidatorTypeValues.age,
  'email': ValidatorTypeValues.email,
};
