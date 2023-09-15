import 'package:MangaReader/asura.dart';
import 'package:MangaReader/search_filter.dart';
import 'package:flutter/material.dart';

import 'generated/manga.dart';
import 'manga_card.dart';

class MangaList extends StatefulWidget {
  static int page = 1;
  final int mangasPerPage;
  String boxName;
  bool isSearch;
  String query;
  SearchFilter filters;
  MangaList({Key? key, required this.mangasPerPage, required this.boxName, this.isSearch = false, this.query = "", required this.filters}) : super(key: key);

  @override
  State<MangaList> createState() => _MangaListState();
}


class _MangaListState extends State<MangaList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderedMangas = asura.getOrderedMangas();
  }

  Asura asura = Asura.getInstance();
  ScrollController controller = ScrollController();
  List<Manga> mangas = [];
  List<Manga> searchMangas = [];
  List<Manga> filteredMangas = [];
  List<Manga> orderedMangas = [];

  int getMaxPage(){
    if(widget.isSearch){
      return 0;
    }
    return (orderedMangas.length / widget.mangasPerPage).ceil();
  }

  void loadPage(){
    mangas = [];
    int page = MangaList.page;
    int max = widget.mangasPerPage * page;
    int min = widget.mangasPerPage * (page - 1);
    mangas.addAll(orderedMangas.getRange(min, max > orderedMangas.length ? orderedMangas.length : max));
    setState(() {});
  }

  void searchQuery() {
    searchMangas = asura.getSearchedMangas(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    loadPage();
    if(widget.isSearch && widget.query != "") {
      searchMangas = asura.getSearchedMangas(widget.query);
    }

    if(widget.filters.isNotEmpty()) {
      filteredMangas = asura.getFilteredMangas(widget.filters);
    }

    return SizedBox(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            mangas.isEmpty
                ? SizedBox(
                height: MediaQuery.of(context).size.height - 155,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Center(child: CircularProgressIndicator(),),
                    Text("Mangas are loading", style: TextStyle(fontSize: 16),),
                  ],
                ),
              )
                : widget.isSearch && !widget.filters.isNotEmpty() ? GridView.count(
              primary: false,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 5,
              childAspectRatio: 0.65,
              padding: const EdgeInsets.symmetric(
                  vertical: 0, horizontal: 5),
              crossAxisCount: 2,
              children: List.generate(searchMangas.length, (index) {
                final manga = searchMangas[index];
                return MangaCard(manga: manga);
              }),
            ) : widget.filters.isNotEmpty() ? GridView.count(
              primary: false,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 5,
              childAspectRatio: 0.65,
              padding: const EdgeInsets.symmetric(
                  vertical: 0, horizontal: 5),
              crossAxisCount: 2,
              children: List.generate(filteredMangas.length, (index) {
                final manga = filteredMangas[index];
                return MangaCard(manga: manga);
              }),
            ) : GridView.count(
              primary: false,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 5,
              childAspectRatio: 0.65,
              padding: const EdgeInsets.symmetric(
                  vertical: 0, horizontal: 5),
              crossAxisCount: 2,
              children: List.generate(mangas.length, (index) {
                final manga = mangas[index];
                return MangaCard(manga: manga);
              }),
            ),
            Visibility(
              visible: getMaxPage() > 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 120,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)),
                      onPressed: MangaList.page - 1 == 0 ? null : (){
                        MangaList.page--;
                        controller.jumpTo(0);
                        loadPage();
                      },
                      child: const Text("Previous", style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                      ),
                      onPressed: MangaList.page + 1 == getMaxPage() ? null : (){
                        MangaList.page++;
                        controller.jumpTo(0);
                        loadPage();
                      },
                      child: const Text("Next", style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}