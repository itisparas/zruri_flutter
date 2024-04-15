enum FormTypeValues {
  text,
  number,
  multiline,
  dropdown,
  autoComplete,
  datePicker
}

final Map<String, FormTypeValues> formTypeMap = {
  'text': FormTypeValues.text,
  'number': FormTypeValues.number,
  'multiline': FormTypeValues.multiline,
  'autoComplete': FormTypeValues.autoComplete,
  'datePicker': FormTypeValues.datePicker,
};
