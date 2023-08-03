import '../generated/manga.dart';

abstract class Parser{

  Future<void> loadManga() async {

  }

  Future<void> loadChapters(Manga manga) async{

  }


}