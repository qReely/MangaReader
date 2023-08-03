import 'package:flutter/foundation.dart';

class SearchFilter {
  late List<String> genres;
  late List<String> statuses;
  late List<int> chapters;
  late List<double> rating;

  SearchFilter({List<String>? genres, List<String>? statuses, List<int>? chapters, List<double>? rating}) {
    this.genres = genres ?? [];
    this.statuses = statuses ?? [];
    this.chapters = chapters ?? [0, 1000];
    this.rating = rating ?? [0.0, 10.0];
  }

  bool isNotEmpty() {
    return !(genres.isEmpty && statuses.isEmpty && listEquals(chapters, [0, 1000]) && listEquals(rating, [0.0, 10.0]));
  }

  void clear() {
    genres.clear();
    statuses.clear();
    chapters[0] = 0;
    chapters[1] = 1000;
    rating[0] = 0.0;
    rating[1] = 10.0;
  }

  void copyWith(SearchFilter filter) {
    clear();
    genres.addAll(filter.genres);
    statuses.addAll(filter.statuses);
    chapters[0] = filter.chapters[0];
    chapters[1] = filter.chapters[1];
    rating[0] = filter.rating[0];
    rating[1] = filter.rating[1];
  }
}