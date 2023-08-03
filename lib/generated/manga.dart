import 'dart:typed_data';

import 'package:hive/hive.dart';

import 'chapter.dart';

part 'manga.g.dart';

@HiveType(typeId: 0, adapterName: 'MangaAdapter')
class Manga {
  @HiveField(0)
  String url; // +
  @HiveField(1)
  String title; // +
  @HiveField(2)
  String rating; // +
  @HiveField(3)
  int totalChapters;
  @HiveField(4)
  String urlImage; // +
  @HiveField(5)
  String status; // +
  @HiveField(6)
  String latestChapter; // +
  @HiveField(7)
  String synopsis; // +
  @HiveField(8)
  bool isFavourite; // +
  @HiveField(9)
  List<Chapter> chapters; // +
  @HiveField(10)
  int totalChapterRead; // +
  @HiveField(11)
  String boxName; // +
  @HiveField(12)
  Uint8List image;
  @HiveField(13)
  List<String> genres;
  @HiveField(14)
  bool topDown = true;
  @HiveField(15)
  bool showUnread = false;
  @HiveField(16)
  bool showRead = false;

  Manga({
    required this.url,
    required this.latestChapter,
    required this.title,
    required this.rating,
    required this.totalChapters,
    required this.urlImage,
    required this.status,
    required this.totalChapterRead,
    required this.synopsis,
    required this.isFavourite,
    required this.chapters,
    required this.boxName,
    required this.image,
    required this.genres
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'latestChapter': latestChapter,
      'title': title,
      'rating': rating,
      'totalChapters': totalChapters,
      'status': status,
      'totalChapterRead': totalChapterRead,
      'synopsis': synopsis,
      'isFavourite': isFavourite,
      'urlImage': urlImage,
      'chapters' : chapters,
      'boxName' : boxName,
      'genres' : genres,
      'image' : image,
    };
  }

  factory Manga.fromJson(Map<String, dynamic> json){
    return Manga(
      url : json['url'],
      latestChapter : json['latestChapter'],
      title : json['title'],
      rating : json['rating'] ?? "No Rating",
      totalChapters : json['totalChapters'] ?? 0,
      urlImage : json['urlImage'],
      status : json['status'] ?? "Unknown",
      totalChapterRead : json['totalChapterRead'],
      synopsis : json['synopsis'],
      isFavourite : json['isFavourite'],
      chapters: json['chapters'],
      boxName: json['boxName'],
      genres: List<String>.from(json['genres']),
      image: json['image'],
    );
  }

  void setTopDown(bool topDown){
    this.topDown = topDown;
  }

  void setShowUnread(bool showUnread){
    this.showUnread = showUnread;
  }

  void setShowRead(bool showRead){
    this.showRead = showRead;
  }

  bool getTopDown() {
    return topDown;
  }

  bool getShowUnread() {
    return showUnread;
  }

  bool getShowRead() {
    return showRead;
  }
}