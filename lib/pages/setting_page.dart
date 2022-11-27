import 'dart:io';

import 'package:fire/constans/color_constants.dart';
import 'package:fire/constans/constants.dart';
import 'package:fire/models/user_chat.dart';
import 'package:fire/providers/chat_provider.dart';
import 'package:fire/providers/setting_provider.dart';
import 'package:fire/widget/loading_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constans/app_contants.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.settingTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
      ),
      body: const SettingPageState(),
    );
  }
}

class SettingPageState extends StatefulWidget {
  const SettingPageState({Key? key}) : super(key: key);

  @override
  State<SettingPageState> createState() => _SettingPageStateState();
}

class _SettingPageStateState extends State<SettingPageState> {
  TextEditingController? controllerNickName;
  TextEditingController? controllerAboutMe;
  String id = "";
  String nickName = "";
  String aboutMe = "";
  String photoUrl = "";
  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;
  final FocusNode focusNodeNickName = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPref(FirestoreConstants.id) ?? "";
      nickName = settingProvider.getPref(FirestoreConstants.nickname) ?? "";
      aboutMe = settingProvider.getPref(FirestoreConstants.aboutMe) ?? "";
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "";
    });
    controllerNickName = TextEditingController(text: nickName);
    controllerAboutMe = TextEditingController(text: aboutMe);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      PickedFile? pickedFile =
          await imagePicker.getImage(source: ImageSource.gallery);

      File? image;
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
      if (image != null) {
        setState(() {
          avatarImageFile = image;
          isLoading = true;
        });
        uploadFile();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask = chatProvider.uploadFile(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      UserChat userChat = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: nickName,
        aboutMe: aboutMe,
      );

      settingProvider
          .updateDateFireStore(
              FirestoreConstants.pathUserCollection, id, userChat.toJason())
          .then(
        (data) async {
          await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Upload success');
        },
      ).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void hundleUpdateData() {
    focusNodeAboutMe.unfocus();
    focusNodeNickName.unfocus();
    setState(() {
      isLoading = true;
    });
    try {
      UserChat updateInfo = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: nickName,
        aboutMe: aboutMe,
      );
      settingProvider
          .updateDateFireStore(
              FirestoreConstants.pathUserCollection, id, updateInfo.toJason())
          .then((data) async {
        await settingProvider.setPref(FirestoreConstants.nickname, nickName);
        await settingProvider.setPref(FirestoreConstants.aboutMe, aboutMe);
        await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      });
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
    }
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CupertinoButton(
          onPressed: getImage,
          child: Container(
            margin: EdgeInsets.all(20),
            child: avatarImageFile == null
                ? photoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(photoUrl,
                            fit: BoxFit.cover, width: 90, height: 90,
                            errorBuilder: (context, object, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 90,
                            color: ColorConstants.greyColor,
                          );
                        }, loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 90,
                            height: 90,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorConstants.themeColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        }),
                      )
                    : const Icon(
                        Icons.account_circle,
                        size: 90,
                        color: ColorConstants.greyColor,
                      )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.file(
                      avatarImageFile!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, bottom: 5, top: 10),
              child: const Text(
                'NickName',
                style: TextStyle(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: ColorConstants.primaryColor),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Sweetic',
                    contentPadding: EdgeInsets.all(5),
                    hintStyle: TextStyle(color: ColorConstants.greyColor),
                  ),
                  controller: controllerNickName,
                  onChanged: (value) {
                    nickName = value;
                  },
                  focusNode: focusNodeNickName,
                ),
              ),
            ),

          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 50, bottom: 50),
          child: TextButton(
            onPressed: hundleUpdateData,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(ColorConstants.primaryColor),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.fromLTRB(30, 10, 30, 10),
              ),
            ),
            child: const Text(
              'Update',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        Positioned(child: isLoading ? const LoadingView() : const SizedBox.shrink()),
      ],
    );
  }
}
