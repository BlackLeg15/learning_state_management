import 'package:equatable/equatable.dart';
import 'package:mobx/mobx.dart';

import '../../../../../../../core/constants/fetch_anime_posts_parameters.dart';
import '../../../../../domain/entities/anime_post_entity.dart';
import '../../../../../domain/params/get_all_posts_params.dart';
import '../../../../../domain/use_cases/get_all_posts_use_case/get_posts_use_case.dart';
import 'params/anime_posts_mobx_store_params.dart';
part 'anime_posts_mobx_store.g.dart';
part 'states/anime_posts_mobx_store_states.dart';

class AnimePostsMobxStore = _AnimePostsMobxStoreBase with _$AnimePostsMobxStore;

abstract class _AnimePostsMobxStoreBase with Store {
  final GetAllPostsUseCase _getAllPostsUseCase;
  @observable
  AnimePostsMobxStoreState _state = AnimePostsMobxInitialState(const <AnimePostEntity>[]);
  AnimePostsMobxStoreState get state => _state;

  _AnimePostsMobxStoreBase(this._getAllPostsUseCase);

  @action
  Future<void> getPosts(FetchPostsMobxParams? params) async {
    _state = FetchingAnimeMobxPostsState(_state.animePosts, _state.page + 1);
    final result = await _getAllPostsUseCase(GetAllPostsParams(_state.page, FetchAnimePostsParameters.postsPerPage));
    _state = result.fold<AnimePostsMobxStoreState>((error) {
      params?.onErrorCallback?.call();
      return AnimePostsMobxErrorState(error.message, _state.animePosts, _state.page);
    }, (fetchedListOfPosts) {
      final listOfPostsToShow = [
        ..._state.animePosts,
        ...fetchedListOfPosts
      ];
      params?.onStateCallback?.call();
      return FetchedAnimeMobxPostsState(listOfPostsToShow, _state.page);
    });
  }
}
