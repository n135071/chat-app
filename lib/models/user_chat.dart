import 'package:fire/constans/firestore_constans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// كلاس لترتيب القيم المعادة من الفاير بيز
class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;

  UserChat({
    required this.id,
    required this.photoUrl,
    required this.nickname,
    required this.aboutMe,

  });

  factory UserChat.fromDocument(DocumentSnapshot doc){
    String aboutMe = "";
    String photoUrl = "";
    String nickename = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickename = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    return UserChat(
        id: doc.id, photoUrl: photoUrl, nickname: nickename, aboutMe: aboutMe);
  }

  Map<String, String> toJason() {
    // فنكشن خاصة بارسال الرسائل الى الفاير بيز
    return {
      FirestoreConstants.id: this.id,
      FirestoreConstants.nickname: this.nickname,
      FirestoreConstants.aboutMe: this.aboutMe,
      FirestoreConstants.photoUrl: this.photoUrl,

    };
  }
}