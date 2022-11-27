import 'package:fire/constans/color_constants.dart';
import 'package:flutter/material.dart';
class LoadingView extends StatefulWidget {
  const LoadingView({Key? key}) : super(key: key);
  @override

  State<LoadingView> createState() => _LoadingViewState();


}
class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child:   const Center(
        child: CircularProgressIndicator(
          color: ColorConstants.themeColor,
        ),
      ),
    );
  }
}