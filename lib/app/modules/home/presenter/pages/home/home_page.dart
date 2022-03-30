import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/anime_post_entity.dart';
import 'home_controller.dart';
import 'state_managers_or_stores/bloc/anime_posts_bloc.dart';
import 'state_managers_or_stores/change_notifier/anime_posts_notifier_store_states.dart';
import 'state_managers_or_stores/mobx/anime_posts_mobx_store.dart';
import 'widgets/anime_post_card_widget.dart';
import 'widgets/home_loading_widget.dart';
import 'widgets/state_manager_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var lockUpdatePostList = false;
  late final HomeController controller;
  late final ScrollController scrollControllerForPagination;
  late StateManager stateManager;
  ReactionDisposer? disposer;
  late VoidCallback fetchAnimePosts;

  @override
  void initState() {
    super.initState();
    initHomePage();
  }

  void initHomePage() {
    getHomeControllerInstance();
    configPagination();
    //initBloc();
    initChangeNotifier();
  }

  void getHomeControllerInstance() {
    controller = Modular.get();
  }

  void configPagination() {
    scrollControllerForPagination = ScrollController();
    scrollControllerForPagination.addListener(() {
      if (canFetch) {
        fetchAnimePosts();
      }
    });
  }

  bool get canFetch => scrollControllerForPagination.offset >= scrollControllerForPagination.position.maxScrollExtent - 100 && !lockUpdatePostList;

  void fetchAnimePostsWithBloc() {
    lockUpdatePostList = true;
    controller.fetchAnimePosts(onFinishFetchPosts);
  }

  void fetchAnimePostsWithMobx() {
    lockUpdatePostList = true;
    controller.fetchAnimePostsWithMobx(onFinishFetchPosts);
  }

  void onFinishFetchPosts() {
    lockUpdatePostList = false;
  }

  void initBloc() {
    setState(() {
      stateManager = StateManager.bloc;
      fetchAnimePosts = fetchAnimePostsWithBloc;
    });
    if (controller.posts.isEmpty) {
      fetchAnimePosts();
    }
  }

  void initMobx() {
    setState(() {
      stateManager = StateManager.mobx;
      fetchAnimePosts = fetchAnimePostsWithMobx;
    });
    disposer = when((_) => controller.animePostsMobxStore.state is AnimePostsMobxErrorState, () {
      final errorMessage = (controller.animePostsMobxStore.state as AnimePostsMobxErrorState).message;
      showSnackBar(errorMessage);
    });
    if (controller.mobxPosts.isEmpty) {
      fetchAnimePosts();
    }
  }

  void showSnackBar(String message, [BuildContext? contextPamareter]) {
    ScaffoldMessenger.of(contextPamareter ?? context).showSnackBar(SnackBar(content: Text(message)));
  }

  void deactivateMobx() {
    disposer?.call();
    disposer = null;
  }

  void initChangeNotifier() {
    final notifierStore = controller.animePostsNotifierStore;
    notifierStore.addListener(listenToErrorStateInNotifierStore);
    setState(() {
      stateManager = StateManager.changeNotifier;
      fetchAnimePosts = fetchAnimePostsWithChangeNotifier;
    });
    if (controller.notifierPosts.isEmpty) {
      fetchAnimePosts();
    }
  }

  void listenToErrorStateInNotifierStore() {
    final notifierStoreState = controller.animePostsNotifierStore.state;
    if (notifierStoreState is AnimePostsNotifierErrorState) {
      showSnackBar(notifierStoreState.message);
    }
  }

  void deactivateChangeNotifier() {
    final notifierStore = controller.animePostsNotifierStore;
    notifierStore.removeListener(listenToErrorStateInNotifierStore);
  }

  void fetchAnimePostsWithChangeNotifier() {
    lockUpdatePostList = true;
    controller.fetchAnimePostsWithChangeNotifier(onFinishFetchPosts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animes'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StateManagerTile(
                  label: 'Bloc',
                  onPressed: () {
                    if (stateManager == StateManager.bloc) return;
                    deactivateCurrentStateManager();
                    initBloc();
                  }),
              StateManagerTile(
                  label: 'MobX',
                  onPressed: () {
                    if (stateManager == StateManager.mobx) return;
                    deactivateCurrentStateManager();
                    initMobx();
                  }),
              StateManagerTile(
                  label: 'CN',
                  onPressed: () {
                    if (stateManager == StateManager.changeNotifier) return;
                    deactivateCurrentStateManager();
                    initChangeNotifier();
                  }),
            ],
          ),
        ],
      ),
      body: Builder(builder: (_) {
        if (stateManager == StateManager.bloc) {
          return BlocConsumer<AnimePostsBloc, AnimePostsState>(
            bloc: controller.animePostsBloc,
            listener: (listenerContext, animePostsState) {
              if (animePostsState is AnimePostsErrorState) {
                showSnackBar(animePostsState.message, listenerContext);
              }
            },
            builder: (_, animePostsState) {
              final animePostsList = controller.posts;
              return animePostsList.isEmpty ? const HomeLoadingWidget() : buildList(animePostsList, animePostsState is FetchingAnimePostsState);
            },
          );
        }
        if (stateManager == StateManager.mobx) {
          return Observer(
            builder: (_) {
              final state = controller.animePostsMobxStore.state;
              final animePostsList = controller.mobxPosts;
              return animePostsList.isEmpty ? const HomeLoadingWidget() : buildList(animePostsList, state is FetchingAnimeMobxPostsState);
            },
          );
        }
        if (stateManager == StateManager.changeNotifier) {
          return AnimatedBuilder(
            animation: controller.animePostsNotifierStore,
            builder: (_, child) {
              final state = controller.animePostsNotifierStore.state;
              final animePostsList = controller.notifierPosts;
              return animePostsList.isEmpty ? const HomeLoadingWidget() : buildList(animePostsList, state is FetchingAnimeNotifierPostsState);
            },
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget buildList(List<AnimePostEntity> animePostsList, bool isLoading) {
    return ListView.builder(
      controller: scrollControllerForPagination,
      itemCount: animePostsList.length + 1,
      itemBuilder: (_, index) {
        if (isTheLastIndexOfTheAnimePostList(animePostsList, index)) {
          return isLoading ? const HomeLoadingWidget() : const SizedBox();
        }
        return AnimePostCardWidget(
          animePost: animePostsList[index],
          onTap: () => onTapAnimePostCard(animePostsList[index].link),
        );
      },
    );
  }

  void deactivateCurrentStateManager() {
    switch (stateManager) {
      case StateManager.bloc:
        //deactivateBloc();
        break;
      case StateManager.mobx:
        deactivateMobx();
        break;
      case StateManager.changeNotifier:
        deactivateChangeNotifier();
        break;
      default:
    }
  }

  bool isTheLastIndexOfTheAnimePostList(List list, int index) => list.length == index;

  FutureOr<void> onTapAnimePostCard(String? link) {
    final url = link ?? '';
    return canLaunch(url).then((answer) {
      answer == true ? launch(url) : showSnackBar('Não foi possível abrir o link');
    }).onError<Exception>((error, stacktrace) {
      showSnackBar(error.toString());
    });
  }
}

enum StateManager { bloc, changeNotifier, mobx, triple }
