// Define the states
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<dynamic> suggestions;

  SearchLoaded(this.suggestions);
  List<Object?> get props => [suggestions];
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}
