import 'package:fire/constans/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeProvider{
  final FirebaseFirestore firebaseFirestore;
  HomeProvider({required this.firebaseFirestore});

  Stream<QuerySnapshot>getStreamfireStore(String pathCollection, int limit,String TextSearch){
    if(TextSearch.isNotEmpty){
      return firebaseFirestore.collection(pathCollection).limit(limit).where(FirestoreConstants.nickname,isEqualTo: TextSearch).snapshots();
    }
    return firebaseFirestore.collection(pathCollection).limit(limit).snapshots();

  }

}