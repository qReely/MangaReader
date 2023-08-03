import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1, adapterName: 'ChapterAdapter')
class Chapter {
  @HiveField(0)
  String url;
  @HiveField(1)
  String name;
  @HiveField(2)
  bool isRead;
  @HiveField(3)
  List<String> imagePaths;
  @HiveField(4)
  List<String> imageUrls;
  @HiveField(5)
  List<int> height;
  @HiveField(6)
  List<int> width;
  bool isDownloading = false;

  Chapter({
    required this.url,
    required this.name,
    required this.isRead,
    required this.imageUrls,
    required this.imagePaths,
    required this.height,
    required this.width,
    // required this.urls,
  });
}