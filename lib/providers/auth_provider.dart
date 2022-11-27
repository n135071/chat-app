import 'package:fire/constans/firestore_constans.dart';
import 'package:fire/models/user_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized, //عدم تسجيل الدخول
  authenticated, //مسجل او مسجل دخوله
  authenticating, //يسجل الان دخوله
  authenticateError, //حدث خطأ بتسجيل الدخول
  authenticateCanceled, //الغاء تسجيل الدخول
}

class AuthProvider extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore;

  // SharedPreferences prefs=SharedPreferences.getInstance() as SharedPreferences;// الوصول لخصائص الشيردبريفرانسز
  final SharedPreferences prefs;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({required this.prefs, required this.firebaseFirestore});

  String? getMyFireBaseid() {
    return prefs.getString(FirestoreConstants.id);
  }

  //توابع حالة تسجيل الدخول
  Future<bool> handleSigIn() async {
    _status = Status.authenticating;
    notifyListeners();
    GoogleSignInAccount? googleUser = await googleSignIn
        .signIn(); //عند الضغط على الزر فسيكون هذا المتحول مسؤول عن اظهار مربع نختار من خلاله حساب الجيميل الخاص بنا
    if (googleUser != null) {
      // المستخدم اختار حساب
      //ربط تسجيل الدخول بالفاير بيز
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        // تخزين المعلومات بالفاير بيز
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      User? firebaseUser = (await firebaseAuth.signInWithCredential(credential))
          .user; // انشاء الحساب
      // عملية التاكد من ان المستخدم  موجود مسبقا ام لا
      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            . //البحث داخل الفير بيز عن المستخدم اذا كان له حساب ام لا
            collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents =
            result.docs; // البيانات العائدة من عملية البحث
        if (documents.length == 0) {
          //تخزين المعلومات للمستخدم الجديد
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            'createsAt': DateTime.now().microsecondsSinceEpoch.toString(),
          });
          // تخزين المعلومات داخل التطبيق
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.nickname, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        }
        //في حال كان للمستخدم حساب فيجب حفظ مهلوماته , حفظ معلومات المستخدم
        else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      // عدم التسجيل
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  //معرفة حالة المستخدم مسجل او لا
  Future<bool> isLoggdedIn() async {
    bool isLoggedIn = await googleSignIn
        .isSignedIn(); // خاصية تعيد ترو اذا كان مسجل و فولس اذا لم يكن مسجل
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  //function for log out
  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}
