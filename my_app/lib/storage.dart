import 'dart:async';
import 'package:flutter/foundation.dart';

//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'firebase_options.dart';

class UserStorage {

  Future<void> writeUserInfo(String name, bool metric, int age) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('users').doc('cins467').set({
      'name': name,
      'metric': metric,
      'age': age,
    }).then((value){
      if (kDebugMode) {
        print('user updated successfully');
      }
    }).catchError((error){
      if (kDebugMode) {
        print('writeUserInfo error: $error');
      }
    });
  }

  Future<String> readUsername() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds = await firestore.collection('users')
      .doc('cins467')
      .get();
    if(ds.data() != null){
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if(data.containsKey('name')){
        return data['name'];
      }
    }
    return 'none';
  }

  Future<bool> readUserMetric() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds = await firestore.collection('users')
      .doc('cins467')
      .get();
    if(ds.data() != null){
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if(data.containsKey('metric')){
        return data['metric'];
      }
    }
    return false;
  }

  Future<int> readUserAge() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds = await firestore.collection('users')
      .doc('cins467')
      .get();
    if(ds.data() != null){
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if(data.containsKey('age')){
        return data['age'];
      }
    }
    return -1;
  }
}
