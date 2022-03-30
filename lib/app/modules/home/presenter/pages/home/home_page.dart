import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/anime_posts_bloc.dart';
import 'change_notifier/anime_posts_notifier_store_states.dart';
import 'home_controller.dart';
import 'mobx/anime_posts_mobx_store.dart';
import 'widgets/anime_post_card_widget.dart';
import 'widgets/home_loading_widget.dart';

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
    stateManager = StateManager.bloc;
    fetchAnimePosts = fetchAnimePostsWithBloc;
    if (controller.posts.isEmpty) {
      fetchAnimePosts();
    }
  }

  void initMobx() {
    stateManager = StateManager.mobx;
    fetchAnimePosts = fetchAnimePostsWithMobx;
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
    stateManager = StateManager.changeNotifier;
    fetchAnimePosts = fetchAnimePostsWithChangeNotifier;
    if (controller.notifierPosts.isEmpty) {
      fetchAnimePosts();
    }
    final notifierStore = controller.animePostsNotifierStore;
    notifierStore.addListener(listenToErrorStateInNotifierStore);
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
              TextButton(
                  child: const Text(
                    'Bloc',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (stateManager == StateManager.bloc) return;
                    deactivateCurrentStateManager();
                    setState(() {
                      initBloc();
                    });
                  }),
              TextButton(
                  child: const Text(
                    'MobX',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (stateManager == StateManager.mobx) return;
                    deactivateCurrentStateManager();
                    setState(() {
                      initMobx();
                    });
                  }),
              TextButton(
                  child: const Text(
                    'CN',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (stateManager == StateManager.changeNotifier) return;
                    deactivateCurrentStateManager();
                    setState(() {
                      initChangeNotifier();
                    });
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
              if (animePostsList.isEmpty) {
                return const HomeLoadingWidget();
              }
              return ListView.builder(
                controller: scrollControllerForPagination,
                itemCount: animePostsList.length + 1,
                itemBuilder: (builderContext, index) {
                  if (isTheLastIndexOfTheAnimePostList(animePostsList, index)) {
                    return animePostsState is FetchingAnimePostsState ? const HomeLoadingWidget() : const SizedBox();
                  }
                  return AnimePostCardWidget(
                    animePost: animePostsList[index],
                    onTap: () => onTapAnimePostCard(animePostsList[index].link),
                  );
                },
              );
            },
          );
        }
        if (stateManager == StateManager.mobx) {
          return Observer(
            builder: (_) {
              final state = controller.animePostsMobxStore.state;
              final animePostsList = controller.mobxPosts;
              if (animePostsList.isEmpty) {
                return const HomeLoadingWidget();
              }
              return ListView.builder(
                controller: scrollControllerForPagination,
                itemCount: animePostsList.length + 1,
                itemBuilder: (_, index) {
                  if (isTheLastIndexOfTheAnimePostList(animePostsList, index)) {
                    return state is FetchingAnimeMobxPostsState ? const HomeLoadingWidget() : const SizedBox();
                  }
                  return AnimePostCardWidget(
                    animePost: animePostsList[index],
                    onTap: () => onTapAnimePostCard(animePostsList[index].link),
                  );
                },
              );
            },
          );
        }
        if (stateManager == StateManager.changeNotifier) {
          return AnimatedBuilder(
            animation: controller.animePostsNotifierStore,
            builder: (_, child) {
              final state = controller.animePostsNotifierStore.state;
              final animePostsList = controller.notifierPosts;
              if (animePostsList.isEmpty) {
                return const HomeLoadingWidget();
              }
              return ListView.builder(
                controller: scrollControllerForPagination,
                itemCount: animePostsList.length + 1,
                itemBuilder: (_, index) {
                  if (isTheLastIndexOfTheAnimePostList(animePostsList, index)) {
                    return state is FetchingAnimeNotifierPostsState ? const HomeLoadingWidget() : const SizedBox();
                  }
                  return AnimePostCardWidget(
                    animePost: animePostsList[index],
                    onTap: () => onTapAnimePostCard(animePostsList[index].link),
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      }),
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
