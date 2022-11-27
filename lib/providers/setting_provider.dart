

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider{
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  SettingProvider({required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage});
  String? getPref(String key){//جلب البيانات من الفاير بيز
  return prefs.getString(key);


  }
  Future<bool>setPref(String key,String value)async{// وضع البيانات لدينا
    return await prefs.setString(key, value);
  }
  UploadTask uploadTask(File Image,String fileName){// تحميل الصورة

    Reference reference=firebaseStorage.ref().child(fileName);
    UploadTask uploadTask=reference.putFile(Image);
    return uploadTask;
  }
  Future<void>updateDateFireStore(String collectionPath,String path,Map<String,String>dateNeedUpdate){//التعديل على البيانات
   try {
      return firebaseFirestore
          .collection(collectionPath)
          .doc(path)
          .update(dateNeedUpdate);
    } catch(e){
     throw Exception(e);
   }
  }

}