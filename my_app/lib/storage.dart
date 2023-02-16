import 'dart:io';
import 'dart:async';
import 'dart:convert';
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

  Future<void> writeUserInfo(String name, bool metric, int age) async {
    try{
      final file = await _localFile;
      // Write the file
      var jsonString = json.encode({
        'name': name,
        'metric': metric,
        'age': age,
      });
      file.writeAsString(jsonString);
    } catch(e){
      if (kDebugMode) {
        print('writeUserInfo error: $e');
      }
    }
  }

  Future<String> readUsername() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      final userData = json.decode(contents);
      return userData['name'];
    } catch (e) {
      // If encountering an error, return 0
      if (kDebugMode) {
        print('readUserInfo error: $e');
      }
      return 'none';
    }
  }

  Future<bool> readUserMetric() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      final userData = json.decode(contents);
      return userData['metric'];
    } catch (e) {
      // If encountering an error, return 0
      if (kDebugMode) {
        print('readUserMetric error: $e');
      }
      return false;
    }
  }

  Future<int> readUserAge() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      final userData = json.decode(contents);
      return userData['age'];
    } catch (e) {
      // If encountering an error, return 0
      if (kDebugMode) {
        print('readUserMetric error: $e');
      }
      return -1;
    }
  }
}
