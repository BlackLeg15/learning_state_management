import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import 'home_controller.dart';
import 'state_managers_or_stores/bloc/anime_posts_bloc.dart';
import 'state_managers_or_stores/change_notifier/anime_posts_notifier_store_states.dart';
import 'state_managers_or_stores/mobx/anime_posts_mobx_store.dart';
import 'widgets/home_loading_widget.dart';
import 'widgets/posts_list_view.dart';
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
  late void Function(VoidCallback) fetchAnimePostsWithStateManager;
  late Widget body;

  @override
  void initState() {
    super.initState();
    initHomePage();
  }

  void initHomePage() {
    getHomeControllerInstance();
    initChangeNotifier();
    fetchAnimePosts = () {
      lockUpdatePostList = true;
      fetchAnimePostsWithStateManager(onFinishFetchPosts);
    };
    configPagination();
  }

  void getHomeControllerInstance() {
    controller = Modular.get();
  }

  void configPagination() {
    scrollControllerForPagination = ScrollController();
    scrollControllerForPagination.addListener(() {
      if (canFetch) fetchAnimePosts();
    });
  }

  bool get canFetch => scrollControllerForPagination.offset >= scrollControllerForPagination.position.maxScrollExtent - 100 && !lockUpdatePostList;

  void onFinishFetchPosts() {
    lockUpdatePostList = false;
  }

  void initBloc() {
    setState(() {
      stateManager = StateManager.bloc;
      body = buildBodyWithBloc;
      fetchAnimePostsWithStateManager = controller.fetchAnimePosts;
    });
    if (controller.posts.isEmpty) {
      fetchAnimePosts();
    }
  }

  Widget get buildBodyWithBloc => BlocConsumer<AnimePostsBloc, AnimePostsState>(
        bloc: controller.animePostsBloc,
        listener: (listenerContext, animePostsState) {
          if (animePostsState is AnimePostsErrorState) {
            showSnackBar(animePostsState.message, listenerContext);
          }
        },
        builder: (_, state) {
          final animePostsList = controller.posts;
          return animePostsList.isEmpty ? const HomeLoadingWidget() : PostsListView(animePostsList, state is FetchingAnimePostsState, scrollControllerForPagination);
        },
      );

  void initMobx() {
    setState(() {
      stateManager = StateManager.mobx;
      body = buildBodyWithMobx;
      fetchAnimePostsWithStateManager = controller.fetchAnimePostsWithMobx;
    });
    disposer = when((_) => controller.animePostsMobxStore.state is AnimePostsMobxErrorState, () {
      final errorMessage = (controller.animePostsMobxStore.state as AnimePostsMobxErrorState).message;
      showSnackBar(errorMessage);
    });
    if (controller.mobxPosts.isEmpty) {
      fetchAnimePosts();
    }
  }

  Widget get buildBodyWithMobx => Observer(
        builder: (_) {
          final state = controller.animePostsMobxStore.state;
          final animePostsList = controller.mobxPosts;
          return animePostsList.isEmpty ? const HomeLoadingWidget() : PostsListView(animePostsList, state is FetchingAnimePostsState, scrollControllerForPagination);
        },
      );

  void initChangeNotifier() {
    controller.animePostsNotifierStore.addListener(listenToErrorStateInNotifierStore);
    setState(() {
      stateManager = StateManager.changeNotifier;
      body = buildBodyWithChangeNotifier;
      fetchAnimePostsWithStateManager = controller.fetchAnimePostsWithChangeNotifier;
    });
    if (controller.notifierPosts.isEmpty) {
      fetchAnimePosts();
    }
  }

  Widget get buildBodyWithChangeNotifier => AnimatedBuilder(
        animation: controller.animePostsNotifierStore,
        builder: (_, child) {
          final state = controller.animePostsNotifierStore.state;
          final animePostsList = controller.notifierPosts;
          return animePostsList.isEmpty ? const HomeLoadingWidget() : PostsListView(animePostsList, state is FetchingAnimePostsState, scrollControllerForPagination);
        },
      );

  void showSnackBar(String message, [BuildContext? contextPamareter]) {
    ScaffoldMessenger.of(contextPamareter ?? context).showSnackBar(SnackBar(content: Text(message)));
  }

  void listenToErrorStateInNotifierStore() {
    final notifierStoreState = controller.animePostsNotifierStore.state;
    if (notifierStoreState is AnimePostsNotifierErrorState) {
      showSnackBar(notifierStoreState.message);
    }
  }

  void deactivateMobx() {
    disposer?.call();
    disposer = null;
  }

  void deactivateChangeNotifier() => controller.animePostsNotifierStore.removeListener(listenToErrorStateInNotifierStore);

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
      body: body,
    );
  }

  void deactivateCurrentStateManager() {
    switch (stateManager) {
      case StateManager.mobx:
        deactivateMobx();
        break;
      case StateManager.changeNotifier:
        deactivateChangeNotifier();
        break;
      default:
    }
  }
}

enum StateManager { bloc, changeNotifier, mobx, triple }
