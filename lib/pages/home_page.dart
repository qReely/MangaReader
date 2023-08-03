import 'package:MangaReader/asura.dart';
import 'package:MangaReader/manga_list.dart';
import 'package:MangaReader/pages/filter_page.dart';
import 'package:MangaReader/search_filter.dart';
import 'package:flutter/material.dart';

enum CurrentBox{
 asurascans, reaperscans, favourites;

 String getUrl(){
   switch(this) {
     case CurrentBox.asurascans: return "http://asura.gg/manga";
     case CurrentBox.reaperscans: return "";

     default: return "";
   }
 }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MANGA_PER_PAGE = 20;

  String query = "";
  bool searchPressed = false;
  bool isSearch = false;
  TextEditingController controller = TextEditingController();
  List<String> genres = [];
  List<String> statuses = [];
  Asura asura = Asura.getInstance();
  SearchFilter filters = SearchFilter();

  @override
  void initState() {
    super.initState();
    genres = asura.getGenres();
    statuses = asura.getStatuses();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  void setFilters(SearchFilter filter) {
    filters.copyWith(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        centerTitle: true,
        title: searchPressed ? TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
        ),
        onTap: () {
          if(filters.isNotEmpty()) {
            filters.clear();
          }
        },
        onChanged: (value) {
          setState(() {
            query = value;
            isSearch = query != "";
          });
        },
        onTapOutside: (event) {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
            searchPressed = false;
            filters.clear();
          }
        },
        ) : const Text("Manga Reader"),
        actions: [
          Visibility(
            visible: searchPressed,
            child: IconButton(
              onPressed: () async {
                var result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterPage(genres: genres, statuses: statuses,);
                  },
                );
                if(result != null) {
                  filters.clear();
                  setFilters(result[0]);
                }
              },
              icon: const Icon(Icons.filter_list),
            ),
          ),
          IconButton(
            onPressed: (){
              setState(() {
                if(searchPressed){
                  query = "";
                  controller.text = "";
                  filters.clear();
                  searchPressed = false;
                  isSearch = false;
                }
                else{
                  isSearch = true;
                  searchPressed = true;
                }
              });
            }, icon: searchPressed ? const Icon(Icons.close) : const Icon(Icons.search),
          ),
        ],
      ),
      body: MangaList(mangasPerPage: MANGA_PER_PAGE, boxName: "asurascans", isSearch: isSearch, query: query, filters: filters));
  }
}
