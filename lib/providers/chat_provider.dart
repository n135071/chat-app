import 'dart:io';
import 'package:fire/constans/constants.dart';
import 'package:fire/models/message_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ChatProvider{
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;// يفيد في التخزين ضمن الفاير بيز

  ChatProvider({required this.prefs,required this.firebaseFirestore,required this.firebaseStorage});



  UploadTask uploadFile(File image,String fileName){//تابع مسؤول عن تخزين الصورة بالفايربيز
    Reference reference=firebaseStorage.ref().child(fileName);
    UploadTask uploadTask=reference.putFile(image);
    return uploadTask;

  }
  Stream<QuerySnapshot>getChatStream(String groupChatId,//تابع لاستقبال الرسائل الاتية من الفاير بيز
      int limit){//متحول يدل على عدد العناصر الاتية من الرسائل

    return firebaseFirestore.collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp)//ترتيب العناصر حسب وقتها
        .limit(limit)
        .snapshots();
  }
  void sendMessage(
      String content,
      int type,
      String groupChatId,// كنحول للتمييز بين محادثة و محادثة اخرى اي دليل لكل محادثة
      String currentUserId//دليل على المستخدم الحالي(مالك الحساب)
      ,String peerId,//متحول يدل على الطرف المقابل
      ){

DocumentReference documentReference=//مكان تخزين الرسالة
firebaseFirestore.collection(FirestoreConstants.pathUserCollection)
    .doc(groupChatId)
    .collection(groupChatId)
    .doc(DateTime.now().microsecondsSinceEpoch.toString());

MessageChat messageChat=MessageChat(//محتوى الرسالة
    idFrom: currentUserId, idTo: peerId, timesTamp: DateTime.now().millisecondsSinceEpoch.toString(),
    content: content, type: type);



FirebaseFirestore.instance.runTransaction((transaction) async {//ارسال الرسالة
  transaction.set(documentReference, messageChat.toJson());//اعطاء امر ارسال الرسالة

});

  }
}
class TypeMessage{
  static const text=0;
  static const image=1;
  static const sticker=2;
}