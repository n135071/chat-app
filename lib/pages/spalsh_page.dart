import 'package:fire/constans/color_constants.dart';
import 'package:fire/pages/home_page.dart';
import 'package:fire/pages/login_page.dart';
import 'package:fire/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
      checkSignedIn();
    });
  }
  void checkSignedIn() async{
    AuthProvider authProvider=context.read<AuthProvider>();
    bool isLoogedIn=await authProvider.isLoggdedIn();
    if(isLoogedIn){// اذا كان المستخدم لدي حساب سينتقل لداخل التطبيق
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage()));
      return ;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LogIn()));

  }


  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  const [
            Image(image: AssetImage('image/icon_app_splash.jpg'),width: 100,height: 100,),
          SizedBox(
            height: 20,
          ),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}