
import '../../../../../core/constants/endpoints.dart';
import '../../../../../core/services/http_service.dart';
import '../../../domain/entities/anime_post_entity.dart';
import '../../../domain/params/get_all_posts_params.dart';
import '../../../infra/datasources/get_all_posts_datasource.dart';
import 'mapper/get_all_posts_from_api_mapper.dart';

class GetAllPostsFromApiDatasource implements GetAllPostsDatasource {
  final GetAllPostsFromApiMapper _mapper;
  final HttpService _httpService;

  GetAllPostsFromApiDatasource(this._httpService, this._mapper);

  @override
  Future<List<AnimePostEntity>> getAllPosts(GetAllPostsParams params) async {
    try {
      final response = await _httpService.get(Endpoints.postsUrl(params.page, params.numberOfPostsPerPage));
      final postList = _mapper.fromJsonList(response.data);
      return postList;
    }catch (e){
      rethrow;
    }
    
  }
}
