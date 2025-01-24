class BottomSheetState {
  final double? height;

  BottomSheetState({this.height});

  factory BottomSheetState.initial(double? height) {
    return BottomSheetState(
      height: height,
    );
  }
  BottomSheetState copyWith({
    double? height,
  }) {
    return BottomSheetState(
      height: height ?? this.height,
    );
  }

  List<Object?> get props => [height];
}
