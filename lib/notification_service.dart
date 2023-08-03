import 'package:MangaReader/parsers/asura_parser.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  int _currentManga = 0;
  String _dots = "";

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(int id, String title, String body, int totalMangas) async {
    print("Show notification");
    _currentManga = 0;

    while(_currentManga < totalMangas && !AsuraParser.latestMangaUpdatedFound){
      await Future.delayed(const Duration(seconds: 1));
      animateDots();
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'manga_notification_id',
          'Main Channel',
          importance: Importance.high,
          priority: Priority.high,
          progress: _currentManga,
          maxProgress: totalMangas,
          showProgress: true,
          ongoing: true,
          onlyAlertOnce: true
      );

      var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
          id,
          "$title$_dots",
          body,
          platformChannelSpecifics,
      );
    }
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'manga_notification_id',
        'Main Channel',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        onlyAlertOnce: true
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id,
        "Check finished successfully!",
        "${AsuraParser.numOfMangasUpdated} Mangas updated\n"
        "${AsuraParser.numOfFavoritesUpdated == 0 ? "No chapters released for Favorite Mangas" :
        "${AsuraParser.numOfFavoritesUpdated} Favorite Mangas were updated"}",
        platformChannelSpecifics,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void incrementCurrentManga() {
    _currentManga+=1;
  }

  void animateDots() {
    if(_dots.length == 3) {
      _dots = ".";
    } else{
      _dots += ".";
    }
  }
}