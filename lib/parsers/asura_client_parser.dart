import 'dart:typed_data';

import 'package:MangaReader/parsers/parser.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

import '../generated/chapter.dart';
import '../generated/manga.dart';
import '../notification_service.dart';
import '../pages/home_page.dart';

// TODO - CHANGE THE WAY OF LOADING CHAPTERS --> CHECK IF IT EXISTS AND PLACE IT IF NOT CREATE NEW

class AsuraClientParser extends Parser{
  String boxName = CurrentBox.asurascans.name;
  final _asuraBox = Hive.box(CurrentBox.asurascans.name);
  final _MANGAS_PER_PAGE = 20;
  final client = http.Client();
  List<Manga> _loadedManga = [];
  static bool latestMangaUpdatedFound = false;
  static int numOfFavoritesUpdated = 0;
  static int numOfMangasUpdated = 0;
  Set<String> _genres = {};
  Set<String> _statuses = {};

  @override
  Future<void> loadManga() async {
    // TODO - add MANGAS to list, then at the end insert to the box
    Stopwatch stopwatch = Stopwatch()..start();
    print("LOADING BEGAN");
    List<String> orderedTitles = [];
    List<String> oldOrderedTitles = [];
    _genres.add("No genres available");
    if(_asuraBox.length > 1){
      oldOrderedTitles = _asuraBox.get("ordered_titles");
    }
    _loadedManga = [];
    numOfFavoritesUpdated = 0;
    numOfMangasUpdated = 0;
    latestMangaUpdatedFound = false;

    Uri url = Uri.parse("https://www.asurascans.com/manga/list-mode/");
    http.Response response = await client.get(url); // todo if throws error try again
    dom.Document html = dom.Document.html(response.body);
    BeautifulSoup bs = BeautifulSoup(html.body!.innerHtml);

    int totalMangas = 0;
    bs.findAll('div', class_: 'blix').forEach((element) {totalMangas += element.ul!.children.length;});
    int totalPages = (totalMangas / _MANGAS_PER_PAGE).ceil();
    NotificationService().showNotification(1, "Checking for new chapter releases", "", totalMangas);

    for(int page = 1; page <= totalPages; page++){
      List<String> titles = [];
      url = Uri.parse("https://www.asurascans.com/manga/?order=update&page=$page");
      response = await client.get(url);
      html = dom.Document.html(response.body);
      bs = BeautifulSoup(html.body!.innerHtml);
      List<Bs4Element> mangaList = bs.findAll('div', class_: 'bsx');
      mangaList.forEach((element) {
        titles.add(element.find('div', class_: 'tt')!.text.trim());
      });
      for (String title in titles) {
        NotificationService().incrementCurrentManga();
        Bs4Element manga = mangaList[titles.indexOf(title)];

        String rating = manga.find('div', class_: 'numscore')?.text == null ? "Unknown" : manga.find('div', class_: 'numscore')!.text;
        String url = manga.find('a')!.attributes['href'].toString();
        // set default img if urlImage is null
        String urlImg = manga.find('img')!.attributes['src'].toString();

        if (_asuraBox.containsKey(title)) {
          Manga existManga = _asuraBox.get(title);
          existManga.rating = rating;
          _asuraBox.put(title, existManga);
          _loadedManga.add(existManga);
        } else {
          Uri uri = Uri.parse(urlImg);
          response = await client.get(uri);
          Uint8List img = response.bodyBytes;

          _loadedManga.add(
              Manga.fromJson({
                'title': title,
                'urlImage': urlImg,
                'url': url,
                'rating': rating,
                'latestChapter': "No chapters",
                'totalChapters': 1,
                'totalChapterRead': 0,
                'synopsis': "No synopsis found",
                'status': "Unknown",
                'isFavourite': false,
                'chapters': List<Chapter>.from([]),
                'boxName': boxName,
                'image' : img,
                'genres' : ["No genres available"],
              })
          );
        }
        if(!latestMangaUpdatedFound){
          _loadChapters(_loadedManga.last);
          oldOrderedTitles.remove(title);
          orderedTitles.add(title);
        }
        else{
          break;
        }
      }
      if(latestMangaUpdatedFound) break;
    }
    orderedTitles.addAll(oldOrderedTitles);
    _asuraBox.put("ordered_titles", orderedTitles);

    _genres.addAll(_asuraBox.get("genres") ?? {});
    _asuraBox.put("genres", _genres.toList());

    _statuses.addAll(_asuraBox.get("statuses") ?? {});
    _asuraBox.put("statuses", _statuses.toList());

    _asuraBox.putAll({ for (var manga in _loadedManga) manga.title : manga });
    print("$boxName mangas loaded in ${stopwatch.elapsed.inSeconds}s");
    client.close();
    stopwatch.stop();
  }

  Future<void> _loadChapters(Manga manga) async {
    final url = Uri.parse(manga.url);
    final response = await client.get(url);
    dom.Document html = dom.Document.html(response.body);
    BeautifulSoup bs = BeautifulSoup(html.body!.innerHtml);

    try{
      List<String> genres = [];
      bs.find('span', class_: 'mgen')!.children.forEach((element) {
        genres.add(element.innerHtml);
        _genres.add(genres.last.toLowerCase());
      });
      manga.genres = genres;
    } catch(e){
      print("Error appeared during the load of ${manga.title} genres");
    }

    try{
      String status = bs.find('div', class_: 'tsinfo')!.i!.text;
      manga.status = status;
      _statuses.add(status.toLowerCase());
    }
    catch(e){
      print("Error appeared during the load of ${manga.title} status");
    }

    try{
      String synopsis = "";
      bs.find('div', class_: 'entry-content entry-content-single')!.findAll('p').forEach((element) {
        synopsis += "${element.text}\n";
      });
      synopsis.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
      manga.synopsis = synopsis;
    } catch(e){
      print("Error appeared during the load of ${manga.title} genres");
    }

    List<Chapter> chapterCopy = manga.chapters;
    int chapterLengthsCopy = manga.totalChapters;

    try{
      String latestChapter = "";
      List<String> names = [];
      bs.findAll('span', class_: 'chapternum').forEach((element) {names.add(element.text);});
      latestChapter = names.isNotEmpty ? names[0] : "No chapters";

      List<String> urls = [];
      bs.find('ul', class_: 'clstyle')!.children.forEach((element) => urls.add(element.a!.attributes['href'].toString()));

      if(latestChapter == manga.latestChapter && latestChapter != "No chapters"){
        if(manga.chapters.isNotEmpty && latestChapter == manga.chapters.last.name) {
          latestMangaUpdatedFound = true;
          return;
        }
      }
      if(names.isEmpty) return;
      numOfMangasUpdated+=1;
      if(manga.isFavourite) numOfFavoritesUpdated += 1;

      manga.totalChapters = urls.length;
      List<Chapter> newlyReleasedChapters = List<Chapter>.from([]);
      // if some chapters deleted, but new one released ? ? ? -> loop till i find the latestchpater name ? ? ?
      int idx = 0;
      while(idx < names.length && manga.latestChapter != names[idx]){
        idx+=1;
      }
      for(int i = 0; i < idx; i++){
        newlyReleasedChapters.add(
          Chapter(
            url: urls[i],
            name: names[i],
            isRead: false,
            imagePaths: [],
            imageUrls: [],
            height: [],
            width: [],
          ),
        );
      }
      newlyReleasedChapters.addAll(manga.chapters);
      manga.chapters = newlyReleasedChapters;
      manga.latestChapter = latestChapter;
    }
    catch(e){
      print("Unexpected error during the load of ${manga.title} chapters:");
      print(e.toString());
      manga.totalChapters = chapterLengthsCopy;
      manga.chapters = chapterCopy;
    }
    _loadedManga.add(manga);
  }
}