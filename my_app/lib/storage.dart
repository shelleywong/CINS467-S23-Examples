import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

const String tableUser = 'userTable';
const String columnId = '_id';
const String columnName = 'name';
const String columnMetric = 'metric';
const String columnAge = 'age';

class UserObject {
  late int id;
  late String name;
  late bool metric;
  late int age;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnId: id,
      columnName: name,
      columnMetric: metric == true ? 1 : 0,
      columnAge: age,
    };
    return map;
  }

  UserObject();

  UserObject.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    metric = map[columnMetric] == 1;
    age = map[columnAge];
  }
}

class UserStorage {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableUser (
  $columnId integer primary key autoincrement,
  $columnName text not null,
  $columnMetric integer not null,
  $columnAge integer not null)
''');
    });
  }

  Future<UserObject> insert(UserObject user) async {
    user.id = await db.insert(tableUser, user.toMap());
    return user;
  }

  Future<UserObject> getUser(int id) async {
    List<Map> maps = await db.query(tableUser,
        columns: [columnId, columnName, columnMetric, columnAge],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserObject.fromMap(maps.first);
    }
    UserObject uo = UserObject();
    uo.id = id;
    uo.name = '';
    uo.metric = true;
    uo.age = -1;
    uo = await insert(uo);
    return uo;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableUser, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(UserObject user) async {
    return await db.update(tableUser, user.toMap(),
        where: '$columnId = ?', whereArgs: [user.id]);
  }

  Future close() async => db.close();

  Future<void> writeUserInfo(String name, bool metric, int age) async {
    try{
      await open('myuserdata.db');
      UserObject uo = UserObject();
      uo.name = name;
      uo.metric = metric;
      uo.age = age;
      uo.id = 1;
      await update(uo);
    } catch(e){
      if (kDebugMode) {
        print('writeUserInfo error: $e');
      }
    }
  }

  Future<String> readUsername() async {
    try {
      await open('myuserdata.db');
      UserObject uo = await getUser(1);
      return uo.name;
    } catch (e) {
      // If encountering an error, return 0
      if (kDebugMode) {
        print('readUsername error: $e');
      }
      return 'none';
    }
  }

  Future<bool> readUserMetric() async {
    try {
      await open('myuserdata.db');
      UserObject uo = await getUser(1);
      return uo.metric;
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
      await open('myuserdata.db');
      UserObject uo = await getUser(1);
      return uo.age;
    } catch (e) {
      // If encountering an error, return 0
      if (kDebugMode) {
        print('readUserAge error: $e');
      }
      return -1;
    }
  }
}
