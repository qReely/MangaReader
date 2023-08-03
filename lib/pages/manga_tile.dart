import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:MangaReader/pages/downloading_service.dart';
import 'package:MangaReader/pages/reading_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../asura.dart';
import '../generated/manga.dart';
import 'manga_detail_page.dart';

class MangaTile extends StatefulWidget {
  Manga manga;
  final int chapter;
  static bool isSelected = false;
  MangaTile({Key? key, required this.manga, required this.chapter}) : super(key: key);

  @override
  State<MangaTile> createState() => _MangaTileState();
}
 // TODO -> ADD ERRORS
class _MangaTileState extends State<MangaTile> {
  int downloaded = 0;
  late int total;
  CancelToken cancelToken = CancelToken();
  late String path;
  CircularProgressIndicator indicator = CircularProgressIndicator();
  var downloadCompleted = Completer();
  final _receivePort = ReceivePort();
  List<String?> ids = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPath();
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, DownloadingService.downloadingPortName);
    FlutterDownloader.registerCallback(DownloadingService.downloadingCallBack);
    _receivePort.listen((message) {
      print('Got message from port: $message');
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _receivePort.close();
    Asura.getInstance().putManga(widget.manga);
  }

  Future compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.path,
      // TODO - MAKE CONFIGURABLE
      quality: 100,
      rotate: 0,
    );
    file.writeAsBytesSync(result!);
  }

  void downloadFile(String url, int index) async {
    try {
      ids.add(await DownloadingService.createDownloadTask(
          url, widget.manga.title, widget.chapter, index));
      if(widget.manga.chapters[widget.chapter].imagePaths.isEmpty) {
        widget.manga.chapters[widget.chapter].imagePaths = [];
      }
      widget.manga.chapters[widget.chapter].imagePaths.add("$path/$index.jpg");

      downloaded += 1;
      await compressFile(File("$path/$index.jpg"));

      print("Downloaded: $downloaded");
      if(total == downloaded) {
        downloaded = 0;
        total = 0;
        downloadCompleted.complete();
      }
    } catch (e) {
      print(e);
    }
  }

  Future getPath() async {
    var storage = await getApplicationDocumentsDirectory();
    path = "${storage.path}/mangas/${widget.manga.title}/${widget.chapter}";
  }

  cancelDownload() {
    ids.forEach((element) {FlutterDownloader.cancel(taskId: element!);});
    deleteImages();
  }

  beginDownload() async {
    widget.manga.chapters[widget.chapter].isDownloading = true;
    if(widget.manga.chapters[widget.chapter].imageUrls.isEmpty) {
      await getImages(widget.manga.title, widget.manga.chapters[widget.chapter].url, widget.chapter);
    }
    int length = widget.manga.chapters[widget.chapter].imageUrls.length;

    total = length;

    for(int i = 0; i < length; i++) {
      downloadFile(widget.manga.chapters[widget.chapter].imageUrls[i], i);
    }
    await downloadCompleted.future.whenComplete(() {
      widget.manga.chapters[widget.chapter].isDownloading = false;
      Asura.getInstance().putManga(widget.manga);
      Manga manga = Asura.getInstance().box.get(widget.manga.title);
      ids.clear();
      setState(() {

      });
    });

    // download completed -> do smth
  }

  deleteImages() {
    for(String path in widget.manga.chapters[widget.chapter].imagePaths) {
      File(path).delete();
    }
    widget.manga.chapters[widget.chapter].imagePaths.clear();
    Asura.getInstance().putManga(widget.manga);
    // Hive.box("asurascans").put(_manga.title, _manga);
  }


  @override
  Widget build(BuildContext context) {
    // is chapter downloaded ?
    bool isDownloaded = widget.manga.chapters[widget.chapter].imagePaths.isNotEmpty;
    Icon downloadIcon = Icon(isDownloaded ? Icons.delete : Icons.download);

    bool isSelected = MangaDetail.selectedChapters.contains(widget.chapter);
    Icon selectionIcon = Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank);

    Color tileColor = widget.manga.chapters[widget.chapter].isRead ? Colors.black12 : Colors.white;

    return Card(
        elevation: 10,
        shadowColor: Colors.grey.shade100,
        child: ListTile(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: tileColor,
          title: Text(widget.manga.chapters[widget.chapter].name),
          leading: MangaDetail.selectMode.value ? selectionIcon : null,
          trailing: IconButton(
            onPressed: () async {
              if(widget.manga.chapters[widget.chapter].imagePaths.isEmpty) {
                beginDownload();
              }
              else {
                deleteImages();
              }
              setState(() {

              });
              // download or delete chapter
              // if(_chaptersToDownload.contains(idx)) {
              //   _chaptersToDownload.remove(idx);
              //   return;
              // }
              // download images
            },
            icon: widget.manga.chapters[widget.chapter].isDownloading ? (Stack(
              children: [
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      cancelDownload();
                      Future.delayed(Duration(seconds: 3));
                      setState(() {

                      });
                    },
                  ),
                ),
                indicator,
              ],
            )) : downloadIcon,
          ),
          onTap: () async {
            if(MangaDetail.selectMode.value) {
              setState(() {
                changeSelection();
                MangaDetail.change();
              });
              return;
            }
            showLoadingDialog(context);

            if(widget.manga.chapters[widget.chapter].imageUrls.isEmpty){
              await getImages(widget.manga.title, widget.manga.chapters[widget.chapter].url, widget.chapter);
            }

            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReadingPage(
                    manga: Asura.getInstance().box.get(widget.manga.title),
                    chapterIndex: widget.chapter,
                    path: path,
                  )),
            ).then((value) => MangaDetail.change());
          },
          onLongPress: () {
            showChapterDialog(context, widget.chapter);
          },
        ),
    );
  }

  void changeSelection() {
    if(MangaDetail.selectedChapters.contains(widget.chapter)) {
      MangaDetail.selectedChapters.remove(widget.chapter);
    }
    else{
      MangaDetail.selectedChapters.add(widget.chapter);
    }
    if(!MangaDetail.selectMode.value) {
      MangaDetail.update();
    }

    setState(() {});
  }

  showLoadingDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 10),child:const Text("Loading" )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  showChapterDialog(BuildContext context, int index){
    // int index = _manga.chapters.indexWhere((element) => element.name == _chapters[idx].name);
    final asura = Asura.getInstance();

    bool allSelected = MangaDetail.selectedChapters.length == widget.manga.totalChapters;
    String selectAll = allSelected ?  "Deselect all chapters" : "Select all chapters";

    String selectManga = MangaDetail.selectedChapters.contains(index) ? "Deselect chapter" : "Select chapter";

    bool chapterRead = widget.manga.chapters[widget.chapter].isRead;
    String readChapter = chapterRead ? "Mark as unread" : "Mark as read";

    bool previousRead = true;

    for(int i = widget.chapter; i < widget.manga.chapters.length; i++) {
      if(!widget.manga.chapters[i].isRead) {
        previousRead = false;
      }
    }

    String readPrevious = previousRead ? "Unread all previous" : "Read all previous";

    AlertDialog alert = AlertDialog(
        content: SizedBox(
          height: 220,
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 32,),
                  const Icon(Icons.done),
                  const SizedBox(width: 8,),
                  TextButton(onPressed: (){
                    setState(() {
                      changeSelection();
                      Navigator.pop(context);

                  }); }, child: Text(selectManga)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 32,),
                  const Icon(Icons.done_all),
                  const SizedBox(width: 8,),
                  TextButton(onPressed: (){
                    // select - deselect all
                    MangaDetail.selectedChapters.clear();
                    print(MangaDetail.selectedChapters);
                    if(!allSelected) {
                      MangaDetail.selectedChapters.addAll([for(int i = 0; i < widget.manga.totalChapters; i++) i]);
                      print(MangaDetail.selectedChapters);
                    }
                    MangaDetail.selectAll();
                    setState(() {

                    });
                    Navigator.pop(context);
                    }, child: Text(selectAll)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 32,),
                  const Icon(Icons.arrow_circle_right_outlined),
                  const SizedBox(width: 8,),
                  TextButton(onPressed: () async {
                    // mark as read
                   asura.setRead(widget.manga, widget.chapter);
                   setState(() {

                   });
                    Navigator.pop(context);
                  }, child: Text(readChapter)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 32,),
                  const Icon(Icons.arrow_circle_down),
                  const SizedBox(width: 8,),
                  TextButton(onPressed: () {
                    for(int i = index; i < widget.manga.chapters.length; i++) {
                      asura.setRead(widget.manga, i);
                    }
                    MangaDetail.change();
                    Navigator.pop(context);
                    setState(() {

                    });
                  }, child: Text(readPrevious)),
                ],
              ),
            ],
          ),
        )
    );
    showDialog(barrierDismissible: true,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
}
