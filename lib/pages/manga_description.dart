import 'package:flutter/material.dart';

import '../generated/manga.dart';

class MangaDescription extends StatelessWidget {
  Manga manga;
  MangaDescription({Key? key, required this.manga}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 300,
          child: Stack(
            children: [
              Center(
                child: Image.memory(
                  manga.image,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Status",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                      manga.status,
                      style: manga.status == "Ongoing"
                          ? TextStyle(
                          color: Colors.green.shade500,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic)
                          : manga.status == "Dropped"
                          ? const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic)
                          : const TextStyle(
                          color: Colors.purple,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Chapters",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "${manga.totalChapters}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic),
                      )
                    ],
                  )),
              Align(
                alignment: Alignment.topRight,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      const TextSpan(
                          text: 'Rating: ',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                      TextSpan(
                        text: manga.rating,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Genres",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  manga.genres.toString().substring(1, manga.genres.toString().length - 1),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  "Description",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  manga.synopsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
