import 'package:flutter/material.dart';
class Utilities{
static bool isKeyboordShowing(){
  if(WidgetsBinding.instance !=null){
    return WidgetsBinding.instance.window.viewInsets.bottom>0;
  }
  else{
    return false;
  }

}
static  closeKeyword(BuildContext context){

  FocusScopeNode cureentFocus=FocusScope.of(context);
  if(!cureentFocus.hasPrimaryFocus){
    cureentFocus.unfocus();
  }
}


}