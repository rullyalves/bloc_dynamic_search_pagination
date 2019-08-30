import 'package:github_search/models/search_item.dart';

class SearchResult {
  
  final List<SearchItem> items;

  SearchResult(this.items);

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    //final totalRows = json["total_count"];
    final listItems = List<Map<String, dynamic>>.from((json["items"]))
        ?.map((item) => SearchItem.fromJson(item))
        ?.toList();

    return SearchResult(listItems);
  }
}
