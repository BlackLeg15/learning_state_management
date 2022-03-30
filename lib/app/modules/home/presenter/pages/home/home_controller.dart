import 'package:flutter/material.dart';

import '../../../domain/entities/anime_post_entity.dart';
import 'state_managers_or_stores/change_notifier/anime_posts_notifier_store.dart';
import 'state_managers_or_stores/change_notifier/anime_posts_notifier_store_params.dart';
import 'state_managers_or_stores/mobx/anime_posts_mobx_store.dart';
import 'state_managers_or_stores/bloc/anime_posts_bloc.dart';
import 'state_managers_or_stores/mobx/params/anime_posts_mobx_store_params.dart';

class HomeController {
  final AnimePostsBloc animePostsBloc;
  final AnimePostsMobxStore animePostsMobxStore;
  final AnimePostsNotifierStore animePostsNotifierStore;

  List<AnimePostEntity> get posts => animePostsBloc.state.animePosts;
  List<AnimePostEntity> get mobxPosts => animePostsMobxStore.state.animePosts;
  List<AnimePostEntity> get notifierPosts => animePostsNotifierStore.state.animePosts;
  
  var _anyApiError = false;

  HomeController(this.animePostsBloc, this.animePostsMobxStore, this.animePostsNotifierStore);

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
    animePostsMobxStore.getPosts(FetchPostsMobxParams(
        onErrorCallback: () {
          _anyApiError = true;
        },
        onStateCallback: onSuccess));
  }

  void fetchAnimePostsWithChangeNotifier(VoidCallback onSuccess) {
    if (_anyApiError) return;
    animePostsNotifierStore.getPosts(FetchPostsNotifierParams(
        onErrorCallback: () {
          _anyApiError = true;
        },
        onStateCallback: onSuccess));
  }
}
