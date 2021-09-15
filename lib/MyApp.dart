import 'package:ecg/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Screens/HomeScreen.dart';

class MyApp extends StatelessWidget {
  Map<String, String> env;
  MyApp(this.env);
  initState() {}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Firebase.initializeApp();
    init(env);
    return MaterialApp(
      title: 'ECG Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Montserrat",
        primaryColor: primaryColor,
        scaffoldBackgroundColor: primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: LoginScreen(),
      home: HomeScreen(),
    );
  }

  void init(Map<String, String> env) {
    print('ENV-------->>>>>${env}');
    ENV = env["ENV"];
  }
}
