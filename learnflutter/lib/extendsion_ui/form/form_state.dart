part of 'form_cubit.dart';

/// FormState - Quản lý trạng thái của form
class FormState extends Equatable {
  final String email;
  final String? emailError;
  final String password;
  final String? passwordError;
  final PasswordStrength passwordStrength;
  final String confirmPassword;
  final String? confirmPasswordError;
  final String phone;
  final String? phoneError;
  final String name;
  final String? nameError;
  final String username;
  final String? usernameError;
  final String url;
  final String? urlError;
  final String number;
  final String? numberError;
  final String age;
  final String? ageError;
  final Map<String, String> customFields;
  final Map<String, String?> customFieldErrors;
  final bool isFormValid;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const FormState({
    this.email = '',
    this.emailError,
    this.password = '',
    this.passwordError,
    this.passwordStrength = PasswordStrength.empty,
    this.confirmPassword = '',
    this.confirmPasswordError,
    this.phone = '',
    this.phoneError,
    this.name = '',
    this.nameError,
    this.username = '',
    this.usernameError,
    this.url = '',
    this.urlError,
    this.number = '',
    this.numberError,
    this.age = '',
    this.ageError,
    this.customFields = const {},
    this.customFieldErrors = const {},
    this.isFormValid = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Copy with method để update state
  FormState copyWith({
    String? email,
    String? emailError,
    String? password,
    String? passwordError,
    PasswordStrength? passwordStrength,
    String? confirmPassword,
    String? confirmPasswordError,
    String? phone,
    String? phoneError,
    String? name,
    String? nameError,
    String? username,
    String? usernameError,
    String? url,
    String? urlError,
    String? number,
    String? numberError,
    String? age,
    String? ageError,
    Map<String, String>? customFields,
    Map<String, String?>? customFieldErrors,
    bool? isFormValid,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return FormState(
      email: email ?? this.email,
      emailError: emailError,
      password: password ?? this.password,
      passwordError: passwordError,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordError: confirmPasswordError,
      phone: phone ?? this.phone,
      phoneError: phoneError,
      name: name ?? this.name,
      nameError: nameError,
      username: username ?? this.username,
      usernameError: usernameError,
      url: url ?? this.url,
      urlError: urlError,
      number: number ?? this.number,
      numberError: numberError,
      age: age ?? this.age,
      ageError: ageError,
      customFields: customFields ?? this.customFields,
      customFieldErrors: customFieldErrors ?? this.customFieldErrors,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        emailError,
        password,
        passwordError,
        passwordStrength,
        confirmPassword,
        confirmPasswordError,
        phone,
        phoneError,
        name,
        nameError,
        username,
        usernameError,
        url,
        urlError,
        number,
        numberError,
        age,
        ageError,
        customFields,
        customFieldErrors,
        isFormValid,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
