import 'package:flutter_modular/flutter_modular.dart';

import '../../core/services/http_service.dart';
import 'domain/use_cases/get_all_posts_use_case/get_all_posts_use_case_impl.dart';
import 'external/datasources/api/get_all_posts_from_api_datasource.dart';
import 'external/datasources/api/mapper/get_all_posts_from_api_mapper.dart';
import 'infra/repositories/get_all_posts_repository_impl.dart';
import 'presenter/pages/home/home_controller.dart';
import 'presenter/pages/home/home_page.dart';
import 'presenter/pages/home/state_managers_or_stores/bloc/anime_posts_bloc.dart';
import 'presenter/pages/home/state_managers_or_stores/change_notifier/anime_posts_notifier_store.dart';
import 'presenter/pages/home/state_managers_or_stores/mobx/anime_posts_mobx_store.dart';

class HomeModule extends Module{
  @override
  final List<Bind> binds = [
    Bind((i) => HomeController(i(), i(), i())),
    //Stores
    Bind((i) => AnimePostsBloc(i())),
    Bind((i) => AnimePostsMobxStore(i())),
    Bind((i) => AnimePostsNotifierStore(i())),
    //
    Bind((i) => GetAllPostsUseCaseImpl(i())),
    Bind((i) => GetAllPostsRepositoryImpl(i())),
    Bind((i) => GetAllPostsFromApiDatasource(i(), i())),
    Bind((i) => GetAllPostsFromApiMapper()),
    Bind((i) => HttpService()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => const HomePage())
  ];
}