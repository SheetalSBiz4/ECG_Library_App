import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecg/Models/CaseModel.dart';
import 'package:ecg/Screens/CaseListScreen.dart';
import 'package:ecg/constants.dart';
import 'package:ecg/customs/CustomBlackButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    enableRotation();
  }

  void enableRotation() {
    super.dispose();
    rotateToPortrait();
  }

  void rotateToPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return new WillPopScope(
      onWillPop: () async =>
          SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
      child: Scaffold(
          primary: true,
          appBar: AppBar(
            title: Text(PROJECT_NAME),
            backgroundColor: primaryColor,
            brightness: Brightness.dark,
          ),
          body: Container(
            color: HexColor(color_theme),
            child: SafeArea(
              child: Stack(children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/home_bg.png"),
                          fit: BoxFit.cover),
                      color: HexColor(color_theme)),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                    CustomBlackButton(
                                        label: BEGINNER,
                                        widthSize: size.width / 2,
                                        heightSize: size.height,
                                        margin: EdgeInsets.all(10),
                                        press: () {
                                          navigateToCaseListScreen(context,BEGINNER);
                                        }),
                                    CustomBlackButton(
                                        label: INTERMEDIATE,
                                        widthSize: size.width / 2,
                                        heightSize: size.height,
                                        margin: EdgeInsets.all(10),
                                        press: () {
                                          navigateToCaseListScreen(context,INTERMEDIATE);
                                        }),
                                  ])),
                            ),
                            Expanded(
                              child: Container(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                    CustomBlackButton(
                                        label: ADVANCED,
                                        widthSize: size.width / 2,
                                        heightSize: size.height,
                                        margin: EdgeInsets.all(10),
                                        press: () {
                                          navigateToCaseListScreen(context,ADVANCED);
                                        }),
                                    CustomBlackButton(
                                        label: EXPERT,
                                        widthSize: size.width / 2,
                                        heightSize: size.height,
                                        margin: EdgeInsets.all(10),
                                        press: () {
                                          navigateToCaseListScreen(context,EXPERT);
                                        }),
                                  ])),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          )),
    );
  }

  void navigateToCaseListScreen(BuildContext context, String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CaseListScreen(level)),
    );
  }
}
