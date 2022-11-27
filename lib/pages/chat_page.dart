
import 'dart:io';   // for File
import 'package:fire/constans/color_constants.dart';
import 'package:fire/constans/constants.dart';
import 'package:fire/models/message_chat.dart';
import 'package:fire/pages/full_photo_page.dart';
import 'package:fire/pages/login_page.dart';
import 'package:fire/providers/auth_provider.dart';
import 'package:fire/widget/loading_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';


class ChatPage extends StatefulWidget {
final String peerId;
final String peerAvatar;
final String peerNickname;
const ChatPage({Key? key, required this.peerId, required this.peerAvatar, required this.peerNickname}) : super(key: key);

  @override
  State<ChatPage> createState() => ChatPageState(
    peerId: this.peerId,
    peerAvatar: this.peerAvatar,
    peerNickname: this.peerNickname,

  );
}

class ChatPageState extends State<ChatPage> {
  ChatPageState({Key ? key,required this.peerId,required this.peerAvatar,required this.peerNickname});

  final String peerId;//id الشخص المقابل
  final String peerAvatar;
  late String currentUserId;
  final String peerNickname;
  String groupChatId="";
    int _limit=20;//متحول يدل على عدد الرسائل بالتشات
    int _limitIncrement=20;//متحول يفيد في زيادة عدد الرسائل بالتشات في حال اصبح عددها اكبر من عشرين
  File ? imageFile;
  bool isLoading=false;
  bool isShowSticker=false;
  String imageUrl="";
  final ScrollController listScrollController=ScrollController();// متحول للتحكم بالتشات بالتطبيق
  List <QueryDocumentSnapshot>listMessage=[];
  late ChatProvider chatProvider;
  late AuthProvider authProvider;
 TextEditingController textEditingController=TextEditingController();
final FocusNode focusNode=FocusNode();// المتحول المسؤوول عن اغلاق الكيبورد و فتحه
  @override
  void initState(){
    super.initState();
    readLocal();


 chatProvider=context.read<ChatProvider>();
 authProvider=context.read<AuthProvider>();
 focusNode.addListener(onFocusChange);
 listScrollController.addListener(_scrollListener);
  }
  _scrollListener(){
    //عندما اقلب  برسائل المحادثة فقيمة السكرول كونترولور تتغير
    // فالشرط الاول هو انه اذا كانت قيمة السكرول كونرولر اكبر من القيمة العظمة له
    // الشرط الثاني هو انه اذا قيمة السكرول كونرور ما زالت ضمن المجال
    // الشرط الثالث هو انه اذا كان  عدد العناصر اللي عندي اصغر من عدد العناصر المجلوبة
    if(listScrollController.offset>=listScrollController.position.maxScrollExtent
    && !listScrollController.position.outOfRange
    && _limit<=listMessage.length
    )
      {

        setState(() {
       // زيد عدد العناصر
          _limit+=_limitIncrement;
        });
      }
  }
void readLocal(){
    if(authProvider.getMyFireBaseid()?.isNotEmpty==true){
      currentUserId=authProvider.getMyFireBaseid()!;
    }
    else{
      Navigator.of(context).
      pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LogIn()),
              (Route<dynamic>route) => false);
    }
    if(currentUserId.compareTo(peerId)>0){
      groupChatId='$currentUserId _ $peerId';
    }
    else{
      groupChatId='$peerId _ $currentUserId';

    }
}
  void onFocusChange(){// تابع مسؤول عن اخفاء الستيكر في حال كان الكيبورد مفعل ولاننا نحتاج الفحص بكل دائم سنستدعي التابع في الانتستيت
    if(focusNode.hasFocus){//اذا كان الكيبورد مفعل فاخفي الستيكر
      setState(() {
        isShowSticker=false;
      });
    }
  }
Future getImage()async{// تابع لجلب الصورة من الاستديو
  ImagePicker imagePicker=ImagePicker();// ودجت لها علاقة بالصور تحتاج البحث
PickedFile ? pickedFile;// مخزن مؤقت لللصورة
pickedFile=await imagePicker.getImage(source: ImageSource.gallery);// جلب الصورة من الاستديو
        if(pickedFile!=null){
            imageFile=File(pickedFile.path);
            if(imageFile!=null){
              setState(() {
                isLoading=true;
              });
              uploadFile();
            }
        }

}
getSticker(){// تابع منى اجل حالة قائمة الستيكر ظاهرة ام مخفية
  focusNode.unfocus();//امر باغلاق الكيبورد عند فتح الايموجي
  setState(() {
    isShowSticker=!isShowSticker;
  });
}

Future uploadFile()async{// تابع لتحويل الصورة لرابط و تخزينها بالفاير بيز
 String fileName=DateTime.now().microsecondsSinceEpoch.toString();//تسمية لصورة بوقت اختيارها في الفاي!ر بيز
UploadTask uploadTask=chatProvider.uploadFile(imageFile!, fileName);
try{
  TaskSnapshot  snapshot=await uploadTask;
  imageUrl=await snapshot.ref.getDownloadURL();
  setState(() {

    isLoading=false;
    onSenMessage(imageUrl, TypeMessage.image);
  });

}
on FirebaseException catch(e){
setState(() {
  isLoading=false;


});
Fluttertoast.showToast(msg: e.message??e.toString());
}

}
void onSenMessage(String content,int type){
    if(content.trim().isNotEmpty){
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId, peerId);
   if(
   //معناة الشرط انه اذا اتت رسائل جديدة
   listScrollController.hasClients
   ){
     //انتقل الى الاسفل اي الى اصغر قيمة للسكروول كونترولر
     listScrollController.animateTo(listScrollController.position.minScrollExtent,
         duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
   }
    }
    else{
      Fluttertoast.showToast(msg: 'nothing to send',backgroundColor: ColorConstants.greyColor);
    }

}
Widget buildItem(int index,DocumentSnapshot ? document){// ودجت لبناء عناصر التشات
    if(document!=null){// التحقق من وجود بيانات مرسلة او مستقبلة لدي
      MessageChat messageChat=MessageChat.fromDocument(document);
      if(messageChat.idFrom==currentUserId){//التحقق من ان المستخدم هو المرسل لكي تكون رسالته على الجانب الايمن
        //right
        return Row(
          children: [
            messageChat.type==TypeMessage.text?
            Container(
              padding:  const EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 200,
              decoration: BoxDecoration(
                  color: ColorConstants.greyColor2,
                  borderRadius: BorderRadius.circular(8)),
            margin: EdgeInsets.only(bottom:isLastMessageRight(index)?20:10 ,right:10 ),
              child: Text(
                messageChat.content,
                style: const TextStyle(color: ColorConstants.primaryColor),
              ),
            )
                :messageChat.type==TypeMessage.image?
            Container(
             margin: EdgeInsets.only(bottom:isLastMessageRight(index)?20:10,right: 10 ),
             child: OutlinedButton(onPressed: (){
               Navigator.push(context, MaterialPageRoute
                 (builder: (context)=>FullPhotoPage(url: messageChat.content)));
             }, child: Material(
               borderRadius: const BorderRadius.all(Radius.circular(8)),
               clipBehavior: Clip.hardEdge,
               child: Image.network(messageChat.content,
               loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent?loadingProgress){
                 if(loadingProgress==null)return child;
                 return Container(
                   decoration:const BoxDecoration(
                     color: ColorConstants.greyColor2,
                     borderRadius: BorderRadius.all(Radius.circular(8)),
                   ),
                   width: 200,
                   height: 200,
                   child: Center(
                     child: CircularProgressIndicator(
                       color: ColorConstants.themeColor,
                       value: loadingProgress.expectedTotalBytes!=null?
                       loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                           :null,
                     ),
                   ),
                 );


               },
                 errorBuilder: (context,object,stackTrais){
                 return Material(
                   child: Image.asset(
                     'image/image_not.jpg',width: 200,height: 200,fit: BoxFit.cover,
                   ),
                 );
                 },
                 width: 200,
                 height: 200,
                 fit: BoxFit.cover,
               ),
             ),

             ),
            ):const SizedBox.shrink(),
          ],

        );

      }
      else{//مرحلة المتلقي
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              isLastMessageLeft(index)?
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      peerAvatar,
                      loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent ? loadingProgress){
if(loadingProgress==null)return child;
return Center(
  child: CircularProgressIndicator(
    color: ColorConstants.themeColor,
      value: loadingProgress.expectedTotalBytes!=null? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
          :null,
  ),
);

                    },
                      errorBuilder: (context,object,stackTrace){
                        return const Icon(
                          Icons.account_circle,
                          size: 35,
                          color: ColorConstants.greyColor,
                        );
                      },
                      width: 35,
                        height: 35,
                      fit: BoxFit.cover,
                    ),

                  ):Container(width: 35,),
              messageChat.type==TypeMessage.text?
              Container(
                padding:  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                width: 200,
                decoration: BoxDecoration(
                    color: ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.only(left: 10 ),
                child: Text(
                  messageChat.content,
                  style: const TextStyle(color: Colors.white),
                ),
              ): messageChat.type==TypeMessage.image ?
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(0),
                        ),
                      ),

                      onPressed: (){
Navigator.push(context, MaterialPageRoute(builder: (context)=>
    FullPhotoPage(url: messageChat.content)));
                      },
                        child:Material(
                          borderRadius: const BorderRadius.all(Radius.circular(8),),
                          clipBehavior: Clip.hardEdge,
                          child:Image.network(messageChat.content,
                            loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent?loadingProgress){
                              if(loadingProgress==null)return child;
                              return Container(
                                decoration:const BoxDecoration(
                                  color: ColorConstants.greyColor2,
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ColorConstants.themeColor,
                                    value: loadingProgress.expectedTotalBytes!=null?
                                    loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                        :null,
                                  ),
                                ),
                              );


                            },
                            errorBuilder: (context,object,stackTrais){
                              return Material(
                                child: Image.asset(
                                  'image/image_not.jpg',width: 200,height: 200,fit: BoxFit.cover,
                                ),
                              );
                            },
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ) ,
                        ),
                    ),
                  ):
              const SizedBox.shrink(),
            ],
            ),
            isLastMessageLeft(index)?Container(
              margin:const EdgeInsets.only(left: 50,top: 5,bottom: 5) ,
              child: Text(
                  DateFormat('dd MMM kk: mm').format
                    (DateTime.fromMicrosecondsSinceEpoch
                    (int.parse(messageChat.timesTamp),
                  ),
                  ),
                style: const TextStyle(color: ColorConstants.greyColor,fontSize: 12,fontStyle:FontStyle.italic ),
              ),

            ):
                const SizedBox.shrink(),
          ],
        ),
      );
      }
    }
    else{
      return const SizedBox.shrink();
    }
}
bool isLastMessageLeft(int index){// تابع لمعرفة اخر رسالة من المرسل اليه
    if((index>0&&listMessage[index-1].get(FirestoreConstants.idFrom)==currentUserId)||index==0)
{
  return true;
}
    else{
      return false;
    }
  }
  bool isLastMessageRight(int index){// تابع لمعرفة اخر رسالة من المرسل
    if((index>0&&listMessage[index-1].get(FirestoreConstants.idFrom)!=currentUserId)||index==0)
    {
      return true;
    }
    else{
      return false;
    }
  }
  Future<bool>onBackPress(){// تابع لغلق الكيبورد او الايموجي قبل الخروج من المحادثة
    if(isShowSticker){
      setState(() {
        isShowSticker=false;
      });
    }
    else{
      Navigator.pop(context);
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(peerNickname,style: const TextStyle(color: ColorConstants.primaryColor,)
        ,
      ),
        centerTitle: true,

        ),

      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: [
            buildListMessage(),
            Column(
              children: [
                isShowSticker?buildEmoji():const SizedBox.shrink(),
                buildInput()

              ],
            ),
            buildLoading(),
          ],
        ),
      ),
    );
  }
  Widget buildEmoji(){
  return  SingleChildScrollView(
    child: EmojiPicker(
      onEmojiSelected: (category,emoji){
        textEditingController.text=textEditingController.text + emoji.emoji;
       // onSenMessage(emoji.emoji, TypeMessage.sticker);
      },
config: const Config(
        columns: 7,
),
        ),
  );

  }
  Widget buildLoading(){
    return Positioned(
        child: isLoading?const LoadingView()
            :
        const SizedBox.shrink());
  }
  Widget buildInput(){
    return Row(
children: [
  Material(// ودجت لاؤسال الصور
    color: Colors.white,
    child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 1),
    child: IconButton(
      onPressed: getImage,

      icon: const Icon(Icons.image),
      color: ColorConstants.primaryColor,),

    ),

  ),
  Material(//  ودجت لارسال الستيكر
    color: Colors.white,
    child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 1),
    child: IconButton(
      onPressed:getSticker,
      icon: const Icon(Icons.face),
      color: ColorConstants.primaryColor,),

    ),

  ),
Flexible(
  child: TextField(
   onSubmitted: (value){
onSenMessage(textEditingController.text, TypeMessage.text);
   },
  controller: textEditingController,
  focusNode: focusNode,
  style:   const TextStyle(color: ColorConstants.primaryColor,fontSize: 15),
decoration: const InputDecoration.collapsed(hintText: 'Type your message',
hintStyle: TextStyle(color: ColorConstants.greyColor)
),

  ),
),
  Material(
    color: Colors.white,
    child: Container(
    margin:  const EdgeInsets.symmetric(horizontal: 8),
    width: double.infinity,
    decoration: const BoxDecoration(
      border:
      Border(
        top: BorderSide(
          color: ColorConstants.greyColor2,
          width: 0.5,
        ),

      ),
      color: Colors.white,
    ),
    child: IconButton(onPressed: (){
      onSenMessage(textEditingController.text, TypeMessage.text);
    } ,icon:   const Icon(
        Icons.send,
      color: ColorConstants.primaryColor,

    ),
    ),
    ),

  ),

],
    );
  }
  Widget buildListMessage(){
    return Flexible(
        child: groupChatId.isNotEmpty?StreamBuilder
          (
          stream: chatProvider.getChatStream(groupChatId, _limit),//سترييم تعني من اين ستاتي البيانات
            builder: (BuildContext context,AsyncSnapshot<QuerySnapshot>snapshot){
            if(snapshot.hasData){
              listMessage=snapshot.data!.docs;
              if(listMessage.isNotEmpty){
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,//لجعل العناصر تترتب من تحت لفوق
                    itemBuilder:(context,index){
                   return buildItem(index, snapshot.data?.docs[index]);
                    }

                );
              }
              else{
                return const Center(
                  child: Text('No Message yet'),
                );
              }
            }
            else{
return const Center(child:
CircularProgressIndicator
  (color: ColorConstants.themeColor,),);

            }
            },
        ):
        const Center(child:
        CircularProgressIndicator
          (color: ColorConstants.themeColor,),),


    );
  }
}
