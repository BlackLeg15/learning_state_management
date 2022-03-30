import 'package:equatable/equatable.dart';

import '../../../../../../../core/constants/fetch_anime_posts_parameters.dart';
import '../../../../../domain/entities/anime_post_entity.dart';

abstract class AnimePostsNotifierStoreState extends Equatable {
  final int page;
  final int postsPerPage;
  final List<AnimePostEntity> animePosts;

  const AnimePostsNotifierStoreState(this.animePosts, this.page, this.postsPerPage);

  @override
  List<Object?> get props => [
        page,
        postsPerPage,
        animePosts
      ];
}

class AnimePostsNotifierInitialState extends AnimePostsNotifierStoreState {
  AnimePostsNotifierInitialState(List<AnimePostEntity> animePosts, {int? initialPage}) : super(animePosts, initialPage ?? FetchAnimePostsParameters.initialPage, FetchAnimePostsParameters.postsPerPage);
}

class FetchingAnimeNotifierPostsState extends AnimePostsNotifierStoreState {
  FetchingAnimeNotifierPostsState(List<AnimePostEntity> animePosts, int page) : super(animePosts, page, FetchAnimePostsParameters.postsPerPage);
}

class FetchedAnimeNotifierPostsState extends AnimePostsNotifierStoreState {
  FetchedAnimeNotifierPostsState(List<AnimePostEntity> animePosts, int page) : super(animePosts, page, FetchAnimePostsParameters.postsPerPage);
}

class AnimePostsNotifierErrorState extends AnimePostsNotifierStoreState {
  final String message;

  AnimePostsNotifierErrorState(this.message, List<AnimePostEntity> animePosts, int page) : super(animePosts, page, FetchAnimePostsParameters.postsPerPage);

  @override
  List<Object?> get props => super.props
    ..addAll([
      message.hashCode
    ]);
}
