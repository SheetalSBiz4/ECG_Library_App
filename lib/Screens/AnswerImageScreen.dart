import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';

import '../constants.dart';

// ignore: must_be_immutable
class AnswerImageScreen extends StatefulWidget {
  String attachmentUrl;

  AnswerImageScreen(this.attachmentUrl);

  @override
  _AnswerImageScreenState createState() {
    return _AnswerImageScreenState(this.attachmentUrl);
  }
}

class _AnswerImageScreenState extends State<AnswerImageScreen> {
  bool isShow = false;
  int pageCount;

  bool showAnswer = false;
  bool showReference = false;
  int index = 0;
  PhotoViewController controller;

  bool disabeScroll = false;
  String attachmentUrl;
  var caliperImage = "assets/images/hide.png";

  _AnswerImageScreenState(this.attachmentUrl);

  @override
  Future<void> initState() {
    super.initState();
    controller = PhotoViewController();
    rotateToLandscape();
  }

  void rotateToLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // var bottomBarHeight = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        color: HexColor(color_theme),
        child: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: Container(
            height: size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/home_bg.png"),
                    fit: BoxFit.cover),
                color: HexColor(color_theme)),
            child: Container(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Container(
                      width: size.width,
                      height: size.height - 40,
                      // padding: EdgeInsets.all(0),
                      child: Stack(
                        children: [
                          PhotoView.customChild(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                image: DecorationImage(
                                  image: NetworkImage(attachmentUrl),
                                  // fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            backgroundDecoration:
                                BoxDecoration(color: Colors.white),
                            enableRotation: false,
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 6,
                            initialScale: PhotoViewComputedScale.contained,
                            // basePosition: Alignment.center,
                          ),

                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Image.asset("assets/images/close.png"),
                              iconSize: 25,
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

