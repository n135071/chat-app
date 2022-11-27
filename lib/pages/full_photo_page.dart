import 'package:fire/constans/app_contants.dart';
import 'package:fire/constans/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;
  const FullPhotoPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          AppConstants.fulPhotoTitle,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,


      ),
      body: Container(
        child: PhotoView(imageProvider: NetworkImage(url)),
      ),
    );
  }
}
