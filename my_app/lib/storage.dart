import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class UserStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/userinfo.txt');
  }

  Future<void> writeUserInfo(String name) async {
    try{
      final file = await _localFile;
      // Write the file
      file.writeAsString(name);
    } catch(e){
      if (kDebugMode) {
        print('writeUserInfo error: $e');
      }
    }
  }

  Future<String> readUserInfo() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      if (kDebugMode) {
        print('readUserInfo error: $e');
      }
      return 'none';
    }
  }
}
