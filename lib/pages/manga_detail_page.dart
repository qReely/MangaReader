import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:MangaReader/asura.dart';
import 'package:MangaReader/pages/downloading_service.dart';
import 'package:MangaReader/pages/manga_description.dart';
import 'package:MangaReader/pages/manga_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/lottiefiles.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:path_provider/path_provider.dart';
import '../generated/chapter.dart';
import 'package:lottie/lottie.dart';

import '../generated/manga.dart';

class MangaDetail extends StatefulWidget {
  Manga manga;
  static List<int> selectedChapters = [];
  static var selectMode = ValueNotifier(false);



  MangaDetail({Key? key, required this.manga}) : super(key: key);

  @override
  State<MangaDetail> createState() => _MangaDetailState();

  static update() {
    selectMode.value = !selectMode.value;
  }

  static selectAll() {
    selectMode.value = false;
    selectMode.value = true;
  }

  static change() {
    selectMode.value = !selectMode.value;
    selectMode.value = !selectMode.value;
  }


}

class _MangaDetailState extends State<MangaDetail> with TickerProviderStateMixin {
  late Manga _manga;
  List<Widget> _tabsContent = [];
  List<Chapter> _chapters = [];
  List<int> chaptersToDownload = [];
  final _receivePort = ReceivePort();
  late String path;
  late AnimationController favouritesController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _manga = widget.manga;
    _chapters = List.from(_manga.chapters);
    changeChaptersToShow();
    getPath();
    favouritesController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, DownloadingService.downloadingPortName);
    FlutterDownloader.registerCallback(DownloadingService.downloadingCallBack);
    _receivePort.listen((message) {
      print('Got message from port: $message');
    });
  }

  Future getPath() async {
    var storage = await getApplicationDocumentsDirectory();
    path = "${storage.path}/mangas/${widget.manga.title}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _receivePort.close();
    favouritesController.dispose();
    Asura.getInstance().putManga(widget.manga);
  }

  // Future downloadFile(String url, int chapter, int index) async {
  //   try {
  //     await DownloadingService.createDownloadTask(
  //         url, widget.manga.title, chapter, index);
  //     if(widget.manga.chapters[chapter].imagePaths.isEmpty) {
  //       widget.manga.chapters[chapter].imagePaths = [];
  //     }
  //     print("Index: $index");
  //     widget.manga.chapters[chapter].imagePaths.add("$path/$chapter/$index.jpg");
  //   } catch (e) {
  //     print("error");
  //   }
  // }
  //
  // downloadSelectedChapters() {
  //   MangaDetail.selectedChapters.forEach((element) async { await beginDownload(element); });
  // }
  //
  // beginDownload(int chapter) async {
  //   widget.manga.chapters[chapter].isDownloading = true;
  //   MangaDetail.change();
  //   if(widget.manga.chapters[chapter].imageUrls.isEmpty) {
  //     await getImages(widget.manga.title, widget.manga.chapters[chapter].url, chapter);
  //   }
  //
  //   int length = widget.manga.chapters[chapter].imageUrls.length;
  //
  //   for(int i = 0; i < length; i++) {
  //     await downloadFile(widget.manga.chapters[chapter].imageUrls[i], chapter, i);
  //   }
  //   widget.manga.chapters[chapter].isDownloading = false;
  //   Asura.getInstance().putManga(widget.manga);
  //   setState(() {
  //     print("Download Completed");
  //   });
  // }

  void changeChaptersToShow() {
    bool showReadOnly = _manga.showRead;
    bool showUnreadOnly = _manga.showUnread;
    _chapters = List.from(_manga.chapters);
    if(_manga.topDown) {
      _chapters = _chapters.reversed.toList();
    }

    if(showUnreadOnly && showReadOnly) {
      _chapters.clear();
    }
    else if(showReadOnly) {
      _chapters.removeWhere((element) => !element.isRead);
    }
    else if(showUnreadOnly) {
      _chapters.removeWhere((element) => element.isRead);
    }
    setState(() {});
  }

  void setFavourite() {
    setState(() {
      _manga.isFavourite = !_manga.isFavourite;
      // Hive.box(_manga.boxName).put(_manga.title, _manga);
    });
  }

  @override
  Widget build(BuildContext context) {
    _tabsContent = [MangaDescription(manga: _manga), getChaptersPage()];
    if(widget.manga.isFavourite) {
      setState(() {
        favouritesController.reset();
        favouritesController.animateTo(0.7, curve: Curves.easeIn);
      });
    }
    // LottieFiles.$38634_icons_heart_2
    var favouriteIcon = Lottie.asset(LottieFiles.$38634_icons_heart_2,
        controller: favouritesController);

    IconButton downloadSelected = IconButton(
      onPressed: () async {
        MangaDetail.selectedChapters.sort();

        for(int i = 0; i < MangaDetail.selectedChapters.length; i++) {
          chaptersToDownload.add(MangaDetail.selectedChapters[i]);
          setState(() {
            // _manga.chapters[MangaDetail.selectedChapters[i]].isDownloading = true;
            // downloadSelectedChapters();
          });
        }
      },
      icon: const Icon(Icons.download),
    );

    IconButton closeSelection = IconButton(
        onPressed: () {
          MangaDetail.selectedChapters = [];
          MangaDetail.selectMode.value = false;
          setState(() {});
        },
        icon: const Icon(Icons.close)
    );

    IconButton favouriteButton = IconButton(
      onPressed: () {
        if (favouritesController.status ==
            AnimationStatus.dismissed) {
          favouritesController.reset();
          favouritesController.animateTo(0.4);
        } else {
          favouritesController.reverse();
          favouritesController.animateTo(0);
        }

        setFavourite();
      },
      icon: favouriteIcon,
    );

    return WillPopScope(
      onWillPop: closePage,
      child: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: ValueListenableBuilder(valueListenable: MangaDetail.selectMode, builder: (context, selected, child) {
              return Text(selected ? "Selected: ${MangaDetail.selectedChapters.length} chapters" : _manga.title, style: const TextStyle(fontSize: 16),);
            }),
            actions: [
              ValueListenableBuilder(valueListenable: MangaDetail.selectMode, builder: (context, selected, child) {
                return MangaDetail.selectMode.value ? downloadSelected : const SizedBox(width: 0,);
              }),
              ValueListenableBuilder(valueListenable: MangaDetail.selectMode, builder: (context, selected, chidl) {
                return MangaDetail.selectMode.value ? closeSelection : const SizedBox(width: 0,);
              }),
              favouriteButton,
            ],
            bottom: TabBar(
              tabs: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  height: 40,
                  child: const Center(
                    child: Text(
                      "Description",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  height: 40,
                  child: const Center(
                    child: Text("Chapters", style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            children: _tabsContent,
          ),
        ),
      ),
    );
  }

  Future<bool> closePage() {
    if(MangaDetail.selectMode.value) {
     setState(() {
       MangaDetail.selectedChapters = [];
       MangaDetail.selectMode.value = false;
     });
      return Future(() => false);
    }
    else{
      return Future(() => true);
    }
  }

  Widget getChaptersPage() {
    return Column(
      children: [
        // Icons.swap_vert
        Expanded(
          child: SingleChildScrollView(
            child: ValueListenableBuilder(
              valueListenable: MangaDetail.selectMode,
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: _chapters.length,
                itemBuilder: (BuildContext context, int index) {
                  int idx = _manga.chapters.indexWhere((element) => element.name == _chapters[index].name);
                  return MangaTile(manga: _manga, chapter: idx);
                },
              ),
              builder: (context, selected, tile) {
                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  itemCount: _chapters.length,
                  itemBuilder: (BuildContext context, int index) {
                    int idx = _manga.chapters.indexWhere((element) => element.name == _chapters[index].name);
                    return MangaTile(manga: _manga, chapter: idx);
                  },
                );
              },
            ),
          ),
        ),
        getBottomPanel(),
      ],
    );
  }

  Widget getBottomPanel() {
    return  Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _manga.topDown = !_manga.topDown;
                  _chapters = _chapters.reversed.toList();
                  MangaDetail.selectedChapters = MangaDetail.selectedChapters.reversed.toList();
                  setState(() {

                  });
                  // Hive.box("asurascans").put(_manga.title, _manga);
                });
              },
              icon: Icon(
                _manga.topDown ? Icons.arrow_downward : Icons.arrow_upward,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _manga.showUnread = !_manga.showUnread;
                  changeChaptersToShow();
                  // Hive.box("asurascans").put(_manga.title, _manga);
                });
              },
              icon: Icon(
                _manga.showUnread ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                size: 22,
              ),
            ),
            const Text("Unread only"),
            IconButton(
              onPressed: () {
                setState(() {
                  _manga.showRead = !_manga.showRead;
                  changeChaptersToShow();
                  // Hive.box("asurascans").put(_manga.title, _manga);
                });
              },
              icon: Icon(
                _manga.showRead ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                size: 22,
              ),
            ),
            const Text("Read only"),
          ],
        ),
      ),
    );
  }
}

Future<void> getImages(String title, String mangaUrl, int chapter) async {
  Stopwatch stopwatch = Stopwatch()..start();
  final url = Uri.parse(mangaUrl);
  final response = await http.get(url);
  dom.Document html = dom.Document.html(response.body);
  final imageDetails = html
      .querySelectorAll('p > img')
      .map((element) => '''
      {
      	"src": "${element.attributes['src']}",
      	"width": "${element.attributes['width']}",
      	"height": "${element.attributes['height']}"
      }
      ''').toList();
  List<String> images = [];
  List<int> width = [];
  List<int> height = [];
  for(var detail in imageDetails) {
    final json = jsonDecode(detail);
    images.add(json["src"].toString());
    width.add(int.parse(json["width"]));
    height.add(int.parse(json["height"]));
  }

  Asura.getInstance().saveImages(title, chapter, width, height, images);

  print("Images loaded in ${stopwatch.elapsed.inMilliseconds}");
  stopwatch.stop();
}
