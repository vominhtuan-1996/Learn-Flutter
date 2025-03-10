// Define the Cubit
import 'package:learnflutter/component/search_bar/state/search_bar_state.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';

class SearchCubit extends BaseCubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  Future<void> fetchSuggestions(
    String query,
    Future<List<dynamic>> Function(
      String query,
    ) getSuggestions,
  ) async {
    emit(SearchLoading());
    try {
      // Simulate an API call to fetch suggestions
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final suggestions = await getSuggestions(query);
      // List<String>.generate(10, (index) => 'Suggestion $index for $query');
      emit(SearchLoaded(suggestions));
    } catch (e) {
      emit(SearchError('Error fetching suggestions'));
    }
  }

  Future<void> clearSuggestions() async {
    emit(SearchLoading());
    try {
      // Simulate an API call to fetch suggestions
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final suggestions = [];
      emit(SearchLoaded(suggestions));
    } catch (e) {
      emit(SearchError('Error fetching suggestions'));
    }
  }
}
