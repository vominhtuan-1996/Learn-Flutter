class BaseLoadingState {
  final bool? isLoading;
  final String? message;

  BaseLoadingState({this.isLoading, this.message});

  factory BaseLoadingState.initial(bool? isLoading, String? message) {
    return BaseLoadingState(
      isLoading: isLoading,
      message: message,
    );
  }
  BaseLoadingState copyWith({
    bool? isLoading,
    String? message,
  }) {
    return BaseLoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }

  List<Object?> get props => [isLoading, message];
}
