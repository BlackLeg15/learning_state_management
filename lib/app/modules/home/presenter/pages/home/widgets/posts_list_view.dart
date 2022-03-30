import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/entities/anime_post_entity.dart';
import 'anime_post_card_widget.dart';
import 'home_loading_widget.dart';

class PostsListView extends StatelessWidget {
  final ScrollController scrollControllerForPagination;
  final bool isLoading;
  final List<AnimePostEntity> animePostsList;
  const PostsListView(this.animePostsList, this.isLoading, this.scrollControllerForPagination, {Key? key}) : super(key: key);

  bool isTheLastIndexOfTheAnimePostList(List list, int index) => list.length == index;

  FutureOr<void> onTapAnimePostCard(String? link, BuildContext context) {
    final url = link ?? '';
    return canLaunch(url).then((answer) {
      answer == true ? launch(url) : showSnackBar('Não foi possível abrir o link', context);
    }).onError<Exception>((error, stacktrace) {
      showSnackBar(error.toString(), context);
    });
  }

  void showSnackBar(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollControllerForPagination,
      itemCount: animePostsList.length + 1,
      itemBuilder: (_, index) {
        if (isTheLastIndexOfTheAnimePostList(animePostsList, index)) {
          return isLoading ? const HomeLoadingWidget() : const SizedBox();
        }
        return AnimePostCardWidget(
          animePost: animePostsList[index],
          onTap: () => onTapAnimePostCard(animePostsList[index].link, context),
        );
      },
    );
  }
}
