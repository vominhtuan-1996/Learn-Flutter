import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/features/news/cubit/news_state.dart';
import 'package:learnflutter/features/news/repos/news_repository.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository = NewsRepository();

  NewsCubit() : super(NewsInitial());

  Future<void> fetchNews() async {
    emit(NewsLoading());
    try {
      final baseResponse = await _repository.getTopHeadlines();
      if (baseResponse.isSuccess) {
        emit(NewsSuccess(baseResponse.data ?? [],
            message: baseResponse.message));
      } else {
        emit(NewsError(baseResponse.message));
      }
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}
