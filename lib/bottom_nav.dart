import 'package:MangaReader/pages/favourites_page.dart';
import 'package:MangaReader/pages/home_page.dart';
import 'package:MangaReader/pages/settings_page.dart';
import 'package:MangaReader/parsers/asura_parser.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'asura.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();

}

class _BottomNavState extends State<BottomNav> {
  int delay = 120;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> loadMangas() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      if(Hive.box("asurascans").length <= 1) {
        Workmanager().registerPeriodicTask("loadManga", "loadManga",
          frequency: Duration(minutes: delay),
          constraints: Constraints(networkType: NetworkType.connected,),
          existingWorkPolicy: ExistingWorkPolicy.keep,
          initialDelay: Duration(minutes: delay),
        );
        Workmanager();
        Asura.getInstance().box.put("delay", delay);
        AsuraParser().loadManga();
      }
    }
    else {
      openAppSettings();
    }
  }

  int _selectedIndex = 0;
  final List<Widget> _widgets = [
    const HomePage(),
    const FavouritesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    loadMangas();
    return Scaffold(
      body: Center(
        child: _widgets[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Read Manga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        selectedFontSize: 12,
        showUnselectedLabels: true,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
