class ResponseModel<T> {
  final T data;
  final ResponseEnum responseEnum;

  ResponseModel({required this.data, required this.responseEnum});
}

enum ResponseEnum {
  success,
  fail,
  accountNotRegistered, // login: 404 "account not registered" → ไปหน้าลงทะเบียน
  passwordUserIncorrect,
  duplicateUser,
  duplicateHN,
  patientNoFound,
}
