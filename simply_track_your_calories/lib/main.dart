import 'package:flutter/material.dart';
import 'package:simply_track_your_calories/services/authentication.dart';
import 'package:simply_track_your_calories/pages/root_page.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';

void main(){
  Admob.initialize(getAppID());
  runApp(MyApp());
}
String getAppID() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544~1458002511';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-7865620503229955~9347370233';
  }
  return null;
}
const MaterialColor white = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);
class MyApp extends StatelessWidget {

  final String appTitle = 'Simply track your calories';
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Simply track your calories',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: white,
          backgroundColor: Colors.black,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
