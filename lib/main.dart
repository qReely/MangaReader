import 'dart:async';

import 'package:MangaReader/bottom_nav.dart';
import 'package:MangaReader/pages/home_page.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:MangaReader/parsers/asura_parser.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workmanager/workmanager.dart';

import 'generated/manga.dart';
import 'generated/chapter.dart';
import 'notification_service.dart';

Completer uploadCompleter = Completer();
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Hive.initFlutter();
    Hive.registerAdapter(MangaAdapter());
    Hive.registerAdapter(ChapterAdapter());
    final box = await Hive.openBox("asurascans");
    AsuraParser parser = AsuraParser();

    if(task == "updateManga") {
      print("Update Manga");
      // Stopwatch stopwatch = Stopwatch()..start();
      // await parser.loadManga();
      // uploadCompleter.complete();
      // await uploadCompleter.future.whenComplete(() async {
      //   await Future.delayed(const Duration(seconds: 5));
      // });
      // stopwatch.stop();
      // print("Loaded in ${stopwatch.elapsed.inSeconds}s");
      await box.close();
      return Future.value(true);
    }
    else {
      if(Hive.box("asurascans").isNotEmpty){
        await parser.loadManga();
        uploadCompleter.complete();
        await uploadCompleter.future.whenComplete(() async {
          await Future.delayed(const Duration(seconds: 5));
          await box.close();
        });
      }
      return true;
    }
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MangaAdapter());
  Hive.registerAdapter(ChapterAdapter());
  await Hive.openBox(CurrentBox.asurascans.name);
  await Hive.openBox(CurrentBox.reaperscans.name);

  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );

    Workmanager().initialize(callbackDispatcher);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Something happened");
    });

  NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BottomNav(),
    );
  }
}
