 import 'dart:async';
import 'dart:io';
import 'package:fire/constans/app_contants.dart';
import 'package:fire/constans/color_constants.dart';
import 'package:fire/constans/constants.dart';
import 'package:fire/models/user_chat.dart';
import 'package:fire/pages/chat_page.dart';
import 'package:fire/pages/full_photo_page.dart';
import 'package:fire/pages/setting_page.dart';
import 'package:fire/providers/auth_provider.dart';
import 'package:fire/providers/home_provider.dart';
import 'package:fire/utils/debouncer.dart';
import 'package:fire/utils/utilites.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/popue_choices.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   int _limit=20;
   final ScrollController listScrollControler=ScrollController();
   final int _limitIncrement=20;
   late AuthProvider authProvider;
   late String currentUserId;
   late HomeProvider homeProvider;
   String textSearch="";
  Debouncer searchDebouncer=Debouncer(millisecond: 300);
  TextEditingController searchBarTec=TextEditingController();
  StreamController<bool>btnClearController=StreamController<bool>();

  List<PopuoChoies> choices =<PopuoChoies> [
    PopuoChoies(title: 'Setting',icon: Icons.settings),
    PopuoChoies(title: 'Log out',icon: Icons.exit_to_app),
  ];
  @override
  void initState() {

    super.initState();
    authProvider =context.read<AuthProvider>();
    homeProvider =context.read<HomeProvider>();
    if(authProvider.getMyFireBaseid()?.isNotEmpty==true){
      currentUserId=authProvider.getMyFireBaseid()!;
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LogIn()),
              (Route<dynamic>route) => false
      );
    }
    listScrollControler.addListener(scrollerListner);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    btnClearController.close();
  }

  void scrollerListner(){
  if(listScrollControler.offset>=listScrollControler.position.maxScrollExtent&& ! listScrollControler.position.outOfRange)
  {
    setState(() {
      _limit+=_limitIncrement;
    });

  }
  }
  void onItemMenuPress(PopuoChoies choies){
    if(choies.title=='Log out'){
      handleSignOut();
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const SettingPage()));
    }
  }
  Future<bool>onBackPress(){
    openDialog();
    return Future.value(false);
  }
  Future <void>openDialog()async{
    switch(await showDialog(context: context, builder: (BuildContext context){
      return SimpleDialog(
      clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.zero,
        children: [
          Container(
            color: ColorConstants.themeColor,
            padding: const EdgeInsets.only(bottom: 10,top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const Icon(
                    Icons.exit_to_app,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const Text('Exit App',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Are you sure to exit app ?',
                  style: TextStyle(color: Colors.white70,fontSize:14 ),)
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: (){
              Navigator.pop(context,0);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child:   const Icon(
                    Icons.cancel,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                const Text('Cancel',
                  style:
                  TextStyle(
                    color: ColorConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: (){
              Navigator.pop(context,1);
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: const Icon(
                    Icons.check_circle,
                    color: ColorConstants.primaryColor,

                  ),

                ),
                const Text('yes',
                  style: TextStyle(
                    color: ColorConstants.primaryColor,
                  fontWeight: FontWeight.bold,

                  ),)
              ],
            ),
          ),
        ],
      );

    })){
      case 0:
        break;
      case 1:exit(0);


    }
  }
  Future<void>handleSignOut()async{
    authProvider.handleSignOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute
      (
        builder: (context)=>const LogIn(),
    ),
            (Route<dynamic>route) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent,
      appBar: AppBar(
        title: const Text(AppConstants.homeTitle,
        style: TextStyle(
            color: ColorConstants.primaryColor,
        ),
      ),
        backgroundColor: Colors.grey,
        centerTitle: true,
        actions: [buildPopupMenu()],
      ),
      body: WillPopScope(//ودجت تتحكم بزر الرجوع
        onWillPop: onBackPress,

        child: Column(
          children: [
            buildSearchBar(),
            Expanded(
              child: StreamBuilder(
              stream: homeProvider.getStreamfireStore(FirestoreConstants.pathUserCollection, _limit,textSearch),

                  builder: (BuildContext context , AsyncSnapshot<QuerySnapshot>snapshot){

                if(snapshot.hasData){
                  if((snapshot.data?.docs.length ?? 0)>0){
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder:(context,index)=>builderItem(context,snapshot.data?.docs[index]) ,
                         controller: listScrollControler,
                    );
                  }
                  else{
                    return const Center(
                      child: Text('no users'),
                    );
                  }
                }
                else{
                  return const CircularProgressIndicator(
                    color: ColorConstants.themeColor,
                  );
                }
              }

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar(){
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search,color: ColorConstants.greyColor,size: 20,),
            const SizedBox(
              width: 5,),
            Expanded(
                child:TextFormField(
                  textInputAction: TextInputAction.search,
                  controller: searchBarTec,
                  onChanged: (value){
                    searchDebouncer.run(() {
                      if(value.isNotEmpty){
                        btnClearController.add(true);
                        setState(() {
                          textSearch=value;
                        });
                      }
                      else{
                        btnClearController.add(false);
                        setState(() {
                          textSearch="";
                        });
                      }
                    });
                  },
                  decoration:   const InputDecoration.collapsed(
                      hintText: "search nicke name (you have to type exactly String)",
                    hintStyle: TextStyle(fontSize: 13,color: ColorConstants.greyColor),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
            ),
            deletTextonSearchText(),
          ],
        ),
    );
  }
  //ودجت خاصة لحذف النص باكمله اذا اراد المستخدم
  Widget deletTextonSearchText(){
    return StreamBuilder<bool>(
      stream: btnClearController.stream,

        builder: (context,snapshot){
        return snapshot.data==true?GestureDetector(
          onTap: (){
            searchBarTec.clear();
            btnClearController.add(false);
            setState(() {
              textSearch="";
            });
          },
          child: const Icon(Icons.clear_rounded,color:ColorConstants.greyColor,size: 20,),
        ) :const SizedBox.shrink();
        }

    );
  }
Widget buildPopupMenu(){
    return PopupMenuButton(

      offset: Offset(0, 50),
      elevation: 2,
      splashRadius: 20,
      enabled: true,
      onSelected:onItemMenuPress ,
        itemBuilder: (BuildContext context){
        return choices.map((PopuoChoies choice){
          return PopupMenuItem<PopuoChoies>(
            value: choice,
              child: Row(
                children: [
                  Text(choice.title,style: TextStyle(color: ColorConstants.primaryColor),),

                  Container(
                    width: 50,
                  ),
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                ],
              ),

          );
        }
        ).toList();
          
        }
    );
}
 Widget builderItem(BuildContext context,DocumentSnapshot? document) {
    if(document!=null){
      UserChat userChat=UserChat.fromDocument(document);
      if(userChat.id==currentUserId){
        return const SizedBox.shrink();
      }
      else{
        return Container(
          margin: const EdgeInsets.only(bottom: 10,left: 5,right: 5),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black38),
              shape: MaterialStateProperty.all<OutlinedBorder>(const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10),),
              ),

              ),

            ),

              onPressed: (){
if(Utilities.isKeyboordShowing()){
  Utilities.closeKeyword(context);
}
Navigator.push(context, MaterialPageRoute(
    builder: (context)=>
        ChatPage(
            peerId: userChat.id,
            peerAvatar: userChat.photoUrl,
            peerNickname: userChat.nickname
        )
)
);
              },
              child: Row(
                children: [

                  Flexible(
                    child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text('NickName : ${userChat.nickname}',maxLines: 1,style: const TextStyle(
                            color: ColorConstants.primaryColor
                          ),
                          ),

                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text('About me : ${userChat.aboutMe}',maxLines: 1,style: const TextStyle(
                              color: ColorConstants.primaryColor
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>FullPhotoPage(url: userChat.photoUrl)));
                    },
                    child: Material(
                      child: userChat.photoUrl.isNotEmpty ?Image.network(
                        userChat.photoUrl,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent ? loadingProgress){
                          if(loadingProgress==null){
                            return child;
                          }
                          return SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorConstants.themeColor,
                                value: loadingProgress.expectedTotalBytes!=null?loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context,object,stackTrace){
                          return const Icon(
                            Icons.account_circle,
                            size: 50,
                            color: ColorConstants.greyColor,

                          );
                        },
                      )
                          :const Icon(Icons.account_circle,color: ColorConstants.greyColor,size: 50,),
                    ),
                  ),
                ],
              ),
          ),
        );
      }
    }
else{
  return const SizedBox.shrink();
    }
  }
}
