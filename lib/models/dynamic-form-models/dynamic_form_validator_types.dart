enum ValidatorTypeValues {
  novalidate,
  notEmpty,
  textLength,
  phoneNumber,
  age,
  email
}

final Map<String, ValidatorTypeValues> validatorTypeMap = {
  'novalidate': ValidatorTypeValues.novalidate,
  'notempty': ValidatorTypeValues.notEmpty,
  'textlength': ValidatorTypeValues.textLength,
  'phonenumber': ValidatorTypeValues.phoneNumber,
  'age': ValidatorTypeValues.age,
  'email': ValidatorTypeValues.email,
};
