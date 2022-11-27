import 'package:fire/constans/app_contants.dart';
import 'package:fire/constans/color_constants.dart';
import 'package:fire/pages/home_page.dart';
import 'package:fire/providers/auth_provider.dart';
import 'package:fire/widget/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: 'sign in fail ');
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: 'sign in canceled');
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: 'sign in success');
        break;
      default:
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.loginTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: TextButton(
              onPressed: () async {
                bool isSuccess = await authProvider.handleSigIn();
                if (isSuccess) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
              },
              child: const Text(
                'sign in with google',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                    //MaterialStateProperty تدل على الحالة للزر مثل ضغطة عادية او ضغطة طويلة و نغير من حالته حسب المطلوب
                    if (states.contains(MaterialState.pressed)) {
                      return const Color(0xffdd4b39).withOpacity(0.8);
                    }
                    return const Color(0xffdd4b39);
                  },
                ),
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.fromLTRB(30, 15, 30, 15),
                ),
              ),
            ),
          ),
          Positioned(
              child: authProvider.status == Status.authenticating
                  ? const LoadingView()
                  : const SizedBox.shrink()),
          //Positioned خاصية داخل الستاك تفيد في وضع ودخت فوق ودجت
        ],
      ),
    );
  }
}
