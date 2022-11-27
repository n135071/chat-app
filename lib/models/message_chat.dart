import 'package:fire/constans/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageChat {
  String idFrom; //متحول يدل على ممن ستكون الرسالة
  String idTo; //متول يدل على الى من ستكون الرسالة
  String timesTamp; // متحول يدل على زمن الرسالة
  String content; // متحول يدل على محتويات الرسالة (نص_صورة _ستيكر)
  int type;

  MessageChat({
    required this.idFrom,
    required this.idTo,
    required this.timesTamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    // فنكشن خاصة بارسال الرسائل الى الفاير بيز
    return {
      FirestoreConstants.idFrom: this.idFrom,
      FirestoreConstants.idTo: this.idTo,
      FirestoreConstants.timestamp: this.timesTamp,
      FirestoreConstants.type: this.type,
      FirestoreConstants.content: this.content,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    // الاستقبال من الفاير بيز
    //متحولات تخزين مؤقتة
    String idFrom = doc.get(FirestoreConstants.idFrom); //
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    int type = doc.get(FirestoreConstants.type);
    return MessageChat(
        idFrom: idFrom,
        idTo: idTo,
        timesTamp: timestamp,
        content: content,
        type: type,
    );
  }
}
