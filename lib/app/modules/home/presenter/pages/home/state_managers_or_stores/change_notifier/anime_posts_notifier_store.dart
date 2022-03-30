import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../domain/entities/anime_post_entity.dart';
import '../../../../../domain/errors/get_posts_error.dart';
import '../../../../../domain/params/get_all_posts_params.dart';
import '../../../../../domain/typedefs/get_posts_use_case_typedef.dart';
import '../../../../../domain/use_cases/get_all_posts_use_case/get_posts_use_case.dart';
import 'anime_posts_notifier_store_params.dart';
import 'anime_posts_notifier_store_states.dart';

class AnimePostsNotifierStore extends ChangeNotifier {
  final GetAllPostsUseCase _useCase;
  AnimePostsNotifierStoreState _state;
  AnimePostsNotifierStoreState get state => _state;

  AnimePostsNotifierStore(this._useCase, {FetchedAnimeNotifierPostsState? initialState}) : _state = initialState ?? AnimePostsNotifierInitialState(const <AnimePostEntity>[]);

  Future<void> getPosts(FetchPostsNotifierParams? callbacks) async {
    _setStateToLoadingState();
    final eitherResult = await _tryToGetNewPosts();
    _setNewState(eitherResult, callbacks);
  }

  void _setStateToLoadingState() {
    final newPageNumber = _increasePage();
    _state = FetchingAnimeNotifierPostsState(_state.animePosts, newPageNumber);
    notifyListeners();
  }

  int _increasePage() {
    return _state.page + 1;
  }

  GetPostsResult _tryToGetNewPosts() {
    return _useCase(GetAllPostsParams(_state.page, _state.postsPerPage));
  }

  void _setNewState(Either<GetPostsError, List<AnimePostEntity>> eitherResult, FetchPostsNotifierParams? callbacks) {
    eitherResult.fold((badResult) => _badResultHandler(badResult, callbacks?.onErrorCallback), (goodResult) => _goodResultHandler(goodResult, callbacks?.onStateCallback));
  }

  void _badResultHandler(GetPostsError badResult, VoidCallback? onErrorCallback) {
    _state = AnimePostsNotifierErrorState(badResult.message, _state.animePosts, _state.page);
    notifyListeners();
    onErrorCallback?.call();
  }

  void _goodResultHandler(List<AnimePostEntity> goodResult, VoidCallback? onStateCallback) {
    final newListOfPosts = [
      ..._state.animePosts,
      ...goodResult
    ];
    _state = FetchedAnimeNotifierPostsState(newListOfPosts, _state.page);
    notifyListeners();
    onStateCallback?.call();
  }
}
