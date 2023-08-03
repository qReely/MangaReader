import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

import 'generated/manga.dart';
import 'pages/manga_detail_page.dart';

class MangaCard extends StatefulWidget {
  Manga manga;
  MangaCard({Key? key, required this.manga}) : super(key: key);

  @override
  State<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard> {

  @override
  Widget build(BuildContext context) {
    Manga manga = widget.manga;
    return SizedBox(
      height: 400,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 175,
                width: MediaQuery.of(context).size.width *
                    0.47,
                child: Image(
                  image: MemoryImage(
                      manga.image,
                      scale: 0.3),
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: const EdgeInsets.only(left: 5),
                height: 40,
                child: Text(
                  manga.title,
                  maxLines: 2,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              LinearProgressBar(
                maxSteps: manga.totalChapters,
                currentStep: manga.chapters.where((element) => element.isRead).toList().length,
                progressColor: Colors.blue,
                progressType:
                LinearProgressBar.progressTypeLinear,
                backgroundColor: Colors.grey,
                minHeight: 5,
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: const EdgeInsets.only(left: 5),
                height: 20,
                child: Text(
                  manga.latestChapter,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetail(
                  manga: manga,
                ),
              ),
            );
          },
          onLongPress: (){
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                content: Text( manga.isFavourite ?
                "Remove Manga from Favorites?" : "Add Manga to Favorites?",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      manga.isFavourite = !manga.isFavourite;
                      Hive.box(manga.boxName).put(manga.title, manga);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.cyan, fontSize: 17),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.cyan, fontSize: 17),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}