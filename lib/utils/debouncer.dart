//انشاء محرك البحث


import 'dart:async';
import 'dart:ui';

//عندما يتوقف المستخدم عن الكتابة ابحث
class Debouncer{
  final int millisecond;
  Timer? _timer;
  Debouncer({required this.millisecond});
  run(VoidCallback action)
  {
    _timer?.cancel();
    _timer=Timer(Duration(milliseconds: millisecond), action);
  }

}