import 'dart:io';
import 'dart:convert';

import 'package:MangaReader/generated/chapter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

import '../asura.dart';
import '../generated/manga.dart';

class ReadingPage extends StatefulWidget {
  Manga manga;
  int chapterIndex;
  late int firstLoadedChapter;
  String path;
  ReadingPage({Key? key, required this.manga, required this.chapterIndex, required this.path}) : super(key: key) {
    firstLoadedChapter = chapterIndex;
  }

  // TODO -> CHECK EACH IMAGE -> IF PATH DOESN'T EXIST LOAD FROM NETWORK

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final ScrollController controller = ScrollController();
  List<Widget> images = [];
  bool isDownloading = false, isLoading = false;

  void setRead(int index) {
    if(!widget.manga.chapters[index].isRead) {
      widget.manga.chapters[index].isRead = true;
      widget.manga.totalChapterRead++;
      Hive.box(widget.manga.boxName).put(widget.manga.title, widget.manga);
    }
  }

  Future<void> getImages(String title, String mangaUrl, int chapter) async {
    if(isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      print("Image download began");
    });
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
    List<String> imageUrls = [];
    List<int> width = [];
    List<int> height = [];
    for(var detail in imageDetails) {
      final json = jsonDecode(detail);
      imageUrls.add(json["src"].toString());
      width.add(int.parse(json["width"]));
      height.add(int.parse(json["height"]));
    }

    Asura.getInstance().saveImages(title, chapter, width, height, imageUrls);

    print("Images loaded in ${stopwatch.elapsed.inMilliseconds}");
    stopwatch.stop();
    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    if(images.isEmpty) {
      images.addAll(loadChapter(widget.chapterIndex));

    }
    // TODO: implement initState
    super.initState();

    controller.addListener(() {

      if(controller.position.pixels >= controller.position.maxScrollExtent && !isLoading) {
        if(widget.chapterIndex - 1 > 0 && widget.manga.chapters[widget.chapterIndex - 1].imageUrls.isEmpty) {
          getImages(widget.manga.title, widget.manga.chapters[widget.chapterIndex - 1].url, widget.chapterIndex - 1);
        }
        else {
          Future.delayed(Duration(milliseconds: 500));
        }

        print("set read");
        setRead(widget.chapterIndex);
        widget.chapterIndex -= 1;
        images.addAll(loadChapter(widget.chapterIndex));
        setState(() {

        });
      }
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // jumpTo();

    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return images[index];
            }
          ),
          Visibility(
            visible: isLoading,
            child: const CircularProgressIndicator(),
          )
        ],
      )
    );
  }

  List<Widget> loadChapter(int idx) {
    if(idx < 0 || idx > widget.manga.chapters.length) {
      return [];
    }
    Chapter chapter = widget.manga.chapters[idx];
    List<NetworkImage> images = List.generate(chapter.imageUrls.length, (index) => NetworkImage(chapter.imageUrls[index]));
    List<Widget> chapterImages = [];

    for(int index = 0; index < chapter.imageUrls.length; index++) {
      if(chapter.imagePaths.contains("${widget.path}/$index.jpg")){
        chapterImages.add(imageFromMemory(chapter.imagePaths, index));
      }
      else {
        chapterImages.add(imageLoad(images, idx, index));
      }
    }
    return chapterImages;
  }

  Widget imageFromMemory(List<String> imagePaths, int index) {
    return Stack(
      children: [
        InteractiveViewer(
          maxScale: 2.5,
          minScale: 0.5,
          panEnabled: true,
          child: Image(
            image: FileImage(File(imagePaths[index])),
            fit: BoxFit.fitWidth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Text("${index + 1}/${imagePaths.length}", style: const TextStyle(fontSize: 12, decoration: TextDecoration.none,),),
        ),
      ],
    );
  }

  Widget imageLoad(List<NetworkImage> images, int chapter, int index) {
    return Stack(
      children: [
        InteractiveViewer(
          maxScale: 2.5,
          minScale: 0.5,
          panEnabled: true,
          child: Image(
            image: images[index],
            loadingBuilder: (BuildContext context, child, event) {
              if(event == null){
                return child;
              }
              else{
                int height = widget.manga.chapters[chapter].height[index % widget.manga.chapters[chapter].height.length];
                int width = widget.manga.chapters[chapter].width[index % widget.manga.chapters[chapter].width.length];
                double ratio = (height / width);

                double imgHeight = ratio * MediaQuery.of(context).size.width;

                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: imgHeight,
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: CircularProgressIndicator()
                  ),
                );
              }
            },
            fit: BoxFit.fitWidth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text("${index + 1}/${images.length}", style: const TextStyle(fontSize: 12, decoration: TextDecoration.none,),),
        ),
      ],
    );
  }
}
