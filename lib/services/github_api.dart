import 'package:dio/dio.dart';
import 'package:github_search/models/search_result.dart';

class GithubApi {
  Future<SearchResult> search(String text, int page, int limit) async {
    try {
      final response = await Dio().get(
          "https://api.github.com/search/repositories?q=$text&page=$page&per_page=$limit");

      await Future.delayed(Duration(seconds: 2));
      final result = SearchResult.fromJson(response.data);

      return result;
    } on DioError catch (e) {
      print(e.response.data);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
