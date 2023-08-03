import 'package:MangaReader/search_filter.dart';
import 'package:hive/hive.dart';

import 'generated/chapter.dart';
import 'generated/manga.dart';

class Asura {
  static Asura? _instance;
  var box = Hive.box("asurascans");

  Asura._internal() {}

  static Asura getInstance() {
    _instance ??= Asura._internal();
    return _instance!;
  }

  void putManga(Manga manga) {
    box.put(manga.title, manga);
  }

  void setRead(Manga manga, int chapter) {
    if(manga.chapters[chapter].isRead) {
       manga.totalChapters--;
    }
    else{
      manga.totalChapters++;
    }
    manga.chapters[chapter].isRead = !manga.chapters[chapter].isRead;
    putManga(manga);
  }

  void putChapter(String title, int index, Chapter chapter) {
    Manga manga = box.get(title);
    manga.chapters[index] = chapter;
    box.put(title, manga);
  }

  void saveImages(String title, int chapter, List<int> width, List<int> height, List<String> urls) {
    Manga manga = box.get(title);
    manga.chapters[chapter].width = width;
    manga.chapters[chapter].height = height;
    manga.chapters[chapter].imageUrls = urls;
    box.put(manga.title, manga);
    print("Asura chapter: $chapter");
  }

  List<Manga> getOrderedMangas() {
    List<Manga> orderedMangas = [];
    if(box.containsKey("ordered_titles")){
      List<String> titles = List<String>.from(box.get("ordered_titles"));
      for(String title in titles) {
        orderedMangas.add(box.get(title));
      }
    }
    return orderedMangas;
  }

  List<String> getGenres() {
    List<String> genres = [];
    if(box.containsKey("genres")) {
      genres = box.get("genres");
      genres.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return genres;
  }

  List<String> getStatuses() {
    List<String> statuses = [];
    if(box.containsKey("statuses")) {
      statuses = box.get("statuses");
    }
    return statuses;
  }

  List<Manga> getMangas() {
    List<Manga> mangas = [];
    for(String key in box.keys) {
      if(box.get(key).runtimeType == Manga) {
        mangas.add(box.get(key));
      }
    }
    return mangas;
  }

  List<Manga> getSearchedMangas(String query) {
    List<Manga> searchedMangas = [];
    for(Manga manga in getMangas()) {
      if(manga.title.toLowerCase().contains(query.toLowerCase())){
        searchedMangas.add(manga);
      }
    }
    return searchedMangas;
  }

  List<Manga> getFilteredMangas(SearchFilter filter) {
    List<Manga> filteredMangas = [];

    for(Manga manga in getMangas()) {
      double rating = 0.0;
      try{
        rating = double.parse(manga.rating);
      } catch (e) {
        print(e);
      }
      List<String> genres = [];
      for(String genre in manga.genres) {
        genres.add(genre.toLowerCase());
      }

      if(filter.genres.isNotEmpty && genres.toSet().intersection(filter.genres.toSet()).isEmpty) {
        continue;
      }
      if(filter.statuses.isNotEmpty && !filter.statuses.contains(manga.status.toLowerCase())) {
        continue;
      }
      if(!(manga.totalChapters >= filter.chapters[0] && manga.totalChapters <= filter.chapters[1])) {
        continue;
      }
      if(!(rating >= filter.rating[0] && rating <= filter.rating[1])) {
        continue;
      }
      filteredMangas.add(manga);
    }
    return filteredMangas;
  }

}