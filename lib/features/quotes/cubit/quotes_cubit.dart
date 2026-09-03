import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/quotes_repository.dart';
import 'quotes_state.dart';

class QuotesCubit extends Cubit<QuotesState> {
  final QuotesRepository _repository;

  QuotesCubit(this._repository) : super(QuotesLoading()) {
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    emit(QuotesLoading());
    try {
      final quote = await _repository.fetchRandomQuote();
      emit(QuotesLoaded(quote));
    } catch (e) {
      emit(QuotesError('Could not load a quote right now.'));
    }
  }
}