import 'package:MangaReader/manga_card.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../generated/manga.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final _asuraBox = Hive.box("asurascans");
  List<Manga> _favs = [];
  bool _isLoading = true;
  final List<String> _skip = ["ordered_titles", "loading", "delay", "statuses", "genres"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFavs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites: ${_favs.length}"),
        centerTitle: true,
        toolbarHeight: 60,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : (
      _favs.isEmpty ? const Center(
        child: Text(
          "No Favourite Manga found",
          style: TextStyle(color: Colors.black),
        ),
      ) : GridView.count(
        primary: false,
        shrinkWrap: true,
        mainAxisSpacing: 10,
        crossAxisSpacing: 5,
        childAspectRatio: 0.6,
        padding:
        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        crossAxisCount: 2,
        children: List.generate(
            _favs.isEmpty ? 1 : _favs.length,
                (index) {
              Manga manga = _favs[index];
              return MangaCard(manga: manga,);
            }),
      )),
    );
  }

  void getFavs() {
    _favs = [];
    for(String title in _asuraBox.keys){
      if(_skip.contains(title)){
        break;
      }
      Manga manga = _asuraBox.get(title);
      if(manga.isFavourite){
        _favs.add(manga);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}
