part of 'login_cubit.dart';

/// LoginState - Quản lý state của login
class LoginState extends Equatable {
  final String email;
  final String? emailError;
  final String password;
  final String? passwordError;
  final bool isFormValid;
  final bool isLoading;
  final bool isLoginSuccess;
  final bool isRegistrationSuccess;
  final String? errorMessage;
  final String? successMessage;
  final UserModel? loggedInUser;

  const LoginState({
    this.email = '',
    this.emailError,
    this.password = '',
    this.passwordError,
    this.isFormValid = false,
    this.isLoading = false,
    this.isLoginSuccess = false,
    this.isRegistrationSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.loggedInUser,
  });

  /// Copy with method
  LoginState copyWith({
    String? email,
    String? emailError,
    String? password,
    String? passwordError,
    bool? isFormValid,
    bool? isLoading,
    bool? isLoginSuccess,
    bool? isRegistrationSuccess,
    String? errorMessage,
    String? successMessage,
    UserModel? loggedInUser,
  }) {
    return LoginState(
      email: email ?? this.email,
      emailError: emailError,
      password: password ?? this.password,
      passwordError: passwordError,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
      isRegistrationSuccess: isRegistrationSuccess ?? this.isRegistrationSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
      loggedInUser: loggedInUser ?? this.loggedInUser,
    );
  }

  @override
  List<Object?> get props => [
        email,
        emailError,
        password,
        passwordError,
        isFormValid,
        isLoading,
        isLoginSuccess,
        isRegistrationSuccess,
        errorMessage,
        successMessage,
        loggedInUser,
      ];
}
