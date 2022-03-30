import 'package:flutter/material.dart';

import '../../../domain/entities/anime_post_entity.dart';
import 'bloc/anime_posts_bloc.dart';
import 'mobx/anime_posts_mobx_store.dart';
import 'mobx/params/anime_posts_mobx_store_params.dart';

class HomeController {
  final AnimePostsBloc animePostsBloc;
  final AnimePostsMobxStore animePostsMobxStore;
  List<AnimePostEntity> get posts => animePostsBloc.state.animePosts;
  List<AnimePostEntity> get mobxPosts => animePostsMobxStore.state.animePosts;
  var _anyApiError = false;

  HomeController(this.animePostsBloc, this.animePostsMobxStore);

  void fetchAnimePosts(VoidCallback onSuccess) {
    if (_anyApiError) return;
    animePostsBloc.add(
      FetchAnimePostsEvent(
        onStateCallback: onSuccess,
        onErrorCallback: () {
          _anyApiError = true;
        },
      ),
    );
  }

  void fetchAnimePostsWithMobx(VoidCallback onSuccess) {
    if (_anyApiError) return;
    animePostsMobxStore.getPosts(GetPostsMobxParams(
        onErrorCallback: () {
          _anyApiError = true;
        },
        onStateCallback: onSuccess));
  }
}
