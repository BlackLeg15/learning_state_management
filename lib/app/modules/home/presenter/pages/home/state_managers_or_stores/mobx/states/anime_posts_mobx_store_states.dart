part of '../anime_posts_mobx_store.dart';

abstract class AnimePostsMobxStoreState extends Equatable {
  final int page;
  final int postsPerPage;
  final List<AnimePostEntity> animePosts;

  const AnimePostsMobxStoreState(this.animePosts, this.page, this.postsPerPage);

  @override
  List<Object?> get props => [
        page,
        postsPerPage,
        animePosts
      ];
}

class AnimePostsMobxInitialState extends AnimePostsMobxStoreState {
  AnimePostsMobxInitialState(List<AnimePostEntity> animePosts, {int? initialPage}) : super(animePosts, initialPage ?? FetchAnimePostsParameters.initialPage, FetchAnimePostsParameters.postsPerPage);
}

class FetchingAnimeMobxPostsState extends AnimePostsMobxStoreState {
  FetchingAnimeMobxPostsState(List<AnimePostEntity> animePosts, int page) : super(animePosts, page, FetchAnimePostsParameters.postsPerPage);
}

class FetchedAnimeMobxPostsState extends AnimePostsMobxStoreState {
  FetchedAnimeMobxPostsState(List<AnimePostEntity> animePosts, int page) : super(animePosts, page, FetchAnimePostsParameters.postsPerPage);
}

class AnimePostsMobxErrorState extends AnimePostsMobxStoreState {
  final String message;

  AnimePostsMobxErrorState(this.message, List<AnimePostEntity> animePosts, int page) : super(animePosts, page, FetchAnimePostsParameters.postsPerPage);

  @override
  List<Object?> get props => super.props
    ..addAll([
      message.hashCode
    ]);
}
