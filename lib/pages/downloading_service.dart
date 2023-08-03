import 'dart:io';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadingService {
  static const downloadingPortName = 'downloading';

  static Future<String?> createDownloadTask(String url, String title, int chapter, int index) async {

    var path = await _getPath();
    Directory mangasDir = Directory("$path/mangas");
    if(!mangasDir.existsSync()) {
      await mangasDir.create();
    }

    Directory titleDir = Directory("$path/mangas/$title");
    if(!titleDir.existsSync()) {
      await titleDir.create();
    }

    path = "$path/mangas/$title/$chapter";
    Directory directory = Directory(path);
    if(!directory.existsSync()) {
      await directory.create();
    }

    final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: path,
        fileName: "$index.jpg",
        showNotification: false,
        openFileFromNotification: false,
        saveInPublicStorage: false);

    await Future.delayed(const Duration(seconds: 1));

    if (taskId != null) {
      await FlutterDownloader.open(taskId: taskId);
    }
    return taskId;
  }

  static Future<String> _getPath() async {
    final externalDir = await getApplicationDocumentsDirectory();
    return externalDir.path;
  }

  static downloadingCallBack(id, status, progress) {
    final sendPort = IsolateNameServer.lookupPortByName(downloadingPortName);

    if (sendPort != null) {
      sendPort.send([id, status, progress]);
    } else {
      print('SendPort is null. Cannot find isolate $downloadingPortName');
    }
  }
}