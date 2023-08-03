// import 'package:MangaReader/generated/manga.dart';
// import 'package:MangaReader/parsers/parser.dart';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/dom.dart' as dom;
//
// import '../generated/chapter.dart';
// import '../pages/home_page.dart';
//
// class ReaperParser extends Parser{
//   final reaperBox = Hive.box(CurrentBox.reaperscans.name);
//   String boxName = CurrentBox.reaperscans.name;
//
//   @override
//   Future<void> loadManga() async {
//
//     List<String> orderedTitles = [];
//     Stopwatch stopwatch = Stopwatch()..start();
//     int page = 0;
//     Uri url;
//
//     while(true){
//       page++;
//       url = Uri.parse("https://reaperscans.com/latest/comics?page=$page");
//       final response = await http.get(url);
//       dom.Document html = dom.Document.html(response.body);
//
//       try{
//         final mangaList = html.querySelector('body > div.flex.flex-col.h-screen.justify-between > main > div.mx-auto.max-w-2xl.mt-8.px-4.sm\\:px-6.lg\\:max-w-screen-2xl.space-y-4 > div:nth-child(3) > div > div.grid.grid-cols-1.gap-4.lg\\:grid-cols-4')
//         !.children.toList();
//
//         List<String> titles = mangaList.map((e) => e.text.toString()).toList();
//
//         for(int i = 0; i < titles.length; i++){
//           titles[i] = titles[i].split("\n").where((element) => element.length > 2).toList()[0];
//         }
//         for(int i = 0; i < titles.length; i++){
//           List<String> texts = titles[i].split("\n").where((element) => element.length > 2).toList();
//           String title = texts[0];
//           String latestChapter = mangaList.map((e) => e.text.toString()).toList()[i].split("\n").where((element) => element.length > 2).toList()[1];
//           String rating = "";
//           String urlImage = mangaList[i].innerHtml.substring(mangaList[i].innerHtml.indexOf("src=\"") + 5,
//               mangaList[i].innerHtml.indexOf("src=\"") + 5 + mangaList[i].innerHtml.substring(mangaList[i].innerHtml.indexOf("src=\"") + 5).indexOf("\""));
//           String url = mangaList[i].innerHtml.substring(mangaList[i].innerHtml.indexOf("href=\"") + 6,
//               mangaList[i].innerHtml.indexOf("href=\"") + 6 + mangaList[i].innerHtml.substring(mangaList[i].innerHtml.indexOf("href=\"") + 6).indexOf("\""));
//           if(reaperBox.containsKey(title)){
//             Manga existManga = reaperBox.get(title);
//             existManga.latestChapter = latestChapter;
//           }
//           else{
//             reaperBox.put(
//               title,
//               Manga.fromJson({
//                 'title': title,
//                 'urlImage': urlImage,
//                 'url': url,
//                 'rating': rating,
//                 'latestChapter': latestChapter,
//                 'totalChapters': 10,
//                 'totalChapterRead': 0,
//                 'synopsis': "",
//                 'status': "",
//                 'isFavourite': false,
//                 'chapters': List<Chapter>.from([]),
//                 'boxName' : boxName,
//               }),
//             );
//           }
//           await Future.delayed(const Duration(milliseconds: 800));
//           await loadChapters(reaperBox.get(title));
//         }
//         orderedTitles.addAll(titles);
//         reaperBox.put("ordered_titles", orderedTitles);
//         print("$boxName page loaded in ${stopwatch.elapsed.inSeconds}s");
//       }
//       catch(e){
//         print(e.toString());
//         return;
//       }
//     }
//   }
//
//   @override
//   Future<void> loadChapters(Manga manga) async {
//     Stopwatch stopwatch = Stopwatch()..start();
//     Uri url = Uri.parse(manga.url);
//     http.Response response = await http.get(url);
//     print(response.statusCode);
//     if(response.statusCode == 429){
//       print("Manga: ${manga.title} : error");
//     }
//     dom.Document html = dom.Document.html(response.body);
//
//     String status = html.getElementsByClassName("whitespace-nowrap text-neutral-200")[3].text;
//     String totalChapters = html.getElementsByClassName("whitespace-nowrap text-neutral-200")[4].text;
//     print("Manga: ${manga.title}, status: $status, chapters: $totalChapters");
//
//     final synopsis = html
//         .querySelectorAll('body > div.flex.flex-col.h-screen.justify-between > main > div.mx-auto.py-8.grid.max-w-3xl.grid-cols-1.gap-4.sm\\:px-6.lg\\:max-w-screen-2xl.lg\\:grid-flow-col-dense.lg\\:grid-cols-3 > section > div.focus\\:outline-none.max-w-6xl.bg-white.dark\\:bg-neutral-850.rounded.hidden.lg\\:block > div > p')
//         .map((element) => element.innerHtml.trim())
//         .toList();
//
//     String result = "";
//     for (String synapse in synopsis) {
//       result += synapse.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
//       result += '\n';
//     }
//
//
//     // if(manga.status == status && totalChapters.length == manga.totalChapters){
//     //   stopwatch.stop();
//     //   return;
//     // }
//
//     manga.synopsis = result;
//     manga.status = status;
//
//     List<String> chapterNames = html.querySelectorAll('body > div.flex.flex-col.h-screen.justify-between > main > div.mx-auto.py-8.grid.max-w-3xl.grid-cols-1.gap-4.sm\\:px-6.lg\\:max-w-screen-2xl.lg\\:grid-flow-col-dense.lg\\:grid-cols-3 > div > div.focus\\:outline-none.max-w-6xl.bg-white.dark\\:bg-neutral-850.rounded.mt-6 > div.pb-4 > div > div > ul > li > a > div > div.min-w-0.flex-1.sm\\:flex.sm\\:items-center.sm\\:justify-between > div > div.flex.text-sm > p')
//         .map((element) => element.text.trim()).toList();
//
//     List<String> urls = html
//         .querySelectorAll('body > div.flex.flex-col.h-screen.justify-between > main > div.mx-auto.py-8.grid.max-w-3xl.grid-cols-1.gap-4.sm\\:px-6.lg\\:max-w-screen-2xl.lg\\:grid-flow-col-dense.lg\\:grid-cols-3 > div > div.focus\\:outline-none.max-w-6xl.bg-white.dark\\:bg-neutral-850.rounded.mt-6 > div.pb-4 > div > div > ul > li')
//         .map((element) => element.innerHtml.trim())
//         .toList();
//
//     for(int i = 0; i < urls.length; i++){
//       urls[i] = urls[i].substring(urls[i].indexOf("href=\"") + 6,
//           urls[i].indexOf("href=\"") + 6 + urls[i].substring(urls[i].indexOf("href=\"") + 6).indexOf("\""));
//     }
//
//     int index = 1;
//     // bool empty = false;
//     // while(!empty){
//     //   print("entered while loop");
//     //   index++;
//     //   url = Uri.parse("${manga.url}?page=$index");
//     //   response = await http.get(url);
//     //   dom.Document html = dom.Document.html(response.body);
//     //
//     //   print("${manga.url}?page=$index");
//     //   List<String> urlsList = html
//     //       .querySelectorAll('body > div.flex.flex-col.h-screen.justify-between > main > div.mx-auto.py-8.grid.max-w-3xl.grid-cols-1.gap-4.sm\\:px-6.lg\\:max-w-screen-2xl.lg\\:grid-flow-col-dense.lg\\:grid-cols-3 > div > div.focus\\:outline-none.max-w-6xl.bg-white.dark\\:bg-neutral-850.rounded.mt-6 > div.pb-4 > div > div > ul > li')
//     //       .map((element) => element.innerHtml.trim())
//     //       .toList();
//     //
//     //   print(urlsList);
//     //   if(urlsList.isEmpty){
//     //     empty = true;
//     //   }
//     //
//     //   for(int i = 0; i < urlsList.length; i++){
//     //     urlsList[i] = urlsList[i].substring(urlsList[i].indexOf("href=\"") + 6,
//     //         urlsList[i].indexOf("href=\"") + 6 + urlsList[i].substring(urlsList[i].indexOf("href=\"") + 6).indexOf("\""));
//     //   }
//     //
//     //   List<String> names = html.querySelectorAll('body > div.flex.flex-col.h-screen.justify-between > main > div.mx-auto.py-8.grid.max-w-3xl.grid-cols-1.gap-4.sm\\:px-6.lg\\:max-w-screen-2xl.lg\\:grid-flow-col-dense.lg\\:grid-cols-3 > div > div.focus\\:outline-none.max-w-6xl.bg-white.dark\\:bg-neutral-850.rounded.mt-6 > div.pb-4 > div > div > ul > li > a > div > div.min-w-0.flex-1.sm\\:flex.sm\\:items-center.sm\\:justify-between > div > div.flex.text-sm > p')
//     //       .map((element) => element.text.trim()).toList();
//     //
//     //   urls.addAll(urlsList);
//     //   chapterNames.addAll(names);
//     // }
//
//     for(int i = 0; i < urls.length; i++){
//       if(manga.chapters.length - 1 < i ){
//         manga.chapters.add(Chapter(url: urls[i], name: chapterNames[i], isRead: false));
//       }
//     }
//
//     manga.totalChapters = totalChapters.length;
//     Hive.box(boxName).put(manga.title, manga);
//     print("Manga info loaded in ${stopwatch.elapsed.inMilliseconds}ms");
//     stopwatch.stop();
//   }
// }