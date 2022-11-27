import 'package:fire/constans/app_contants.dart';
import 'package:fire/constans/color_constants.dart';
import 'package:fire/pages/spalsh_page.dart';
import 'package:fire/providers/auth_provider.dart';
import 'package:fire/providers/chat_provider.dart';
import 'package:fire/providers/home_provider.dart';
import 'package:fire/providers/setting_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized();
  await Firebase
      .initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.prefs}) : super(key: key);
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore =
      FirebaseFirestore.instance; // الوصول لجميع خصائص الفاير بيز فاير ستور
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
              prefs: prefs, firebaseFirestore: this.firebaseFirestore),
        ),
        Provider<HomeProvider>(
          create: (_) =>
              HomeProvider(firebaseFirestore: this.firebaseFirestore),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
              prefs: this.prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage),
        ),
        Provider<SettingProvider>(
            create: (_) => SettingProvider(
                  prefs: this.prefs,
                  firebaseFirestore: this.firebaseFirestore,
                  firebaseStorage: this.firebaseStorage,
                ))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appTitle,
        theme: ThemeData(
          primaryColor: ColorConstants.themeColor,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
