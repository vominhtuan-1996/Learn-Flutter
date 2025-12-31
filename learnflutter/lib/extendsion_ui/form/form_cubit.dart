import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'form.dart';

part 'form_state.dart';

/// FormCubit - Quản lý state của form validation
class FormCubit extends Cubit<FormState> {
  FormCubit() : super(const FormState());

  /// Cập nhật giá trị email
  void updateEmail(String email) {
    final emailError = FormValidator.validateEmail(email);
    emit(state.copyWith(
      email: email,
      emailError: emailError,
      isFormValid: _validateForm(
        email: email,
        password: state.password,
        confirmPassword: state.confirmPassword,
      ),
    ));
  }

  /// Cập nhật giá trị password
  void updatePassword(String password) {
    final passwordError = FormValidator.validatePassword(password);
    final passwordStrength = FormValidator.checkPasswordStrength(password);
    emit(state.copyWith(
      password: password,
      passwordError: passwordError,
      passwordStrength: passwordStrength,
      isFormValid: _validateForm(
        email: state.email,
        password: password,
        confirmPassword: state.confirmPassword,
      ),
    ));
  }

  /// Cập nhật giá trị confirm password
  void updateConfirmPassword(String confirmPassword) {
    final confirmError = FormValidator.validateConfirmPassword(state.password, confirmPassword);
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: confirmError,
      isFormValid: _validateForm(
        email: state.email,
        password: state.password,
        confirmPassword: confirmPassword,
      ),
    ));
  }

  /// Cập nhật giá trị phone
  void updatePhone(String phone) {
    final phoneError = FormValidator.validatePhone(phone);
    emit(state.copyWith(
      phone: phone,
      phoneError: phoneError,
    ));
  }

  /// Cập nhật giá trị name
  void updateName(String name) {
    final nameError = FormValidator.validateName(name);
    emit(state.copyWith(
      name: name,
      nameError: nameError,
    ));
  }

  /// Cập nhật giá trị username
  void updateUsername(String username) {
    final usernameError = FormValidator.validateUsername(username);
    emit(state.copyWith(
      username: username,
      usernameError: usernameError,
    ));
  }

  /// Cập nhật giá trị URL
  void updateUrl(String url) {
    final urlError = FormValidator.validateUrl(url);
    emit(state.copyWith(
      url: url,
      urlError: urlError,
    ));
  }

  /// Cập nhật giá trị number
  void updateNumber(String number) {
    final numberError = FormValidator.validateNumber(number);
    emit(state.copyWith(
      number: number,
      numberError: numberError,
    ));
  }

  /// Cập nhật giá trị age
  void updateAge(String age) {
    final ageError = FormValidator.validateAge(age);
    emit(state.copyWith(
      age: age,
      ageError: ageError,
    ));
  }

  /// Cập nhật giá trị custom field
  void updateCustomField(String fieldName, String value, String? Function(String?) validator) {
    final error = validator(value);
    emit(state.copyWith(
      customFields: {
        ...state.customFields,
        fieldName: value,
      },
      customFieldErrors: {
        ...state.customFieldErrors,
        fieldName: error,
      },
    ));
  }

  /// Validate toàn bộ form
  bool validateForm() {
    final emailError = FormValidator.validateEmail(state.email);
    final passwordError = FormValidator.validatePassword(state.password);
    final confirmError =
        FormValidator.validateConfirmPassword(state.password, state.confirmPassword);
    final phoneError = state.phone.isEmpty ? null : FormValidator.validatePhone(state.phone);
    final nameError = state.name.isEmpty ? null : FormValidator.validateName(state.name);
    final usernameError =
        state.username.isEmpty ? null : FormValidator.validateUsername(state.username);

    emit(state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmError,
      phoneError: phoneError,
      nameError: nameError,
      usernameError: usernameError,
      isFormValid: emailError == null &&
          passwordError == null &&
          confirmError == null &&
          phoneError == null &&
          nameError == null &&
          usernameError == null,
    ));

    return state.isFormValid;
  }

  /// Reset form về trạng thái ban đầu
  void resetForm() {
    emit(const FormState());
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  /// Set error message
  void setError(String? errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage));
  }

  /// Set success message
  void setSuccess(String? successMessage) {
    emit(state.copyWith(successMessage: successMessage));
  }

  /// Private method để validate form
  bool _validateForm({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return FormValidator.validateEmail(email) == null &&
        FormValidator.validatePassword(password) == null &&
        FormValidator.validateConfirmPassword(password, confirmPassword) == null;
  }

  /// Get all form data as map
  Map<String, dynamic> getFormData() {
    return {
      'email': state.email,
      'password': state.password,
      'confirmPassword': state.confirmPassword,
      'phone': state.phone,
      'name': state.name,
      'username': state.username,
      'url': state.url,
      'age': state.age,
      'number': state.number,
      ...state.customFields,
    };
  }

  /// Check if any field has error
  bool hasErrors() {
    return state.emailError != null ||
        state.passwordError != null ||
        state.confirmPasswordError != null ||
        state.phoneError != null ||
        state.nameError != null ||
        state.usernameError != null ||
        state.urlError != null ||
        state.ageError != null ||
        state.numberError != null ||
        state.customFieldErrors.values.any((e) => e != null);
  }
}
