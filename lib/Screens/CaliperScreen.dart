import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';

import '../constants.dart';

// ignore: must_be_immutable
class CaliperScreen extends StatefulWidget {
  String attachmentUrl;

  CaliperScreen(this.attachmentUrl);

  @override
  _CaliperScreenState createState() {
    return _CaliperScreenState(this.attachmentUrl);
  }
}

class _CaliperScreenState extends State<CaliperScreen> {
  bool isShow = false;
  int pageCount;

  bool showAnswer = false;
  bool showReference = false;
  int index = 0;
  PhotoViewController controller;

  bool disabeScroll = false;
  String attachmentUrl;
  var caliperImage = "assets/images/hide.png";

  _CaliperScreenState(this.attachmentUrl);

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
                          Visibility(
                              child: ResizableWidget(
                                child: Image.asset(
                                    "assets/images/ic_cliaper_image.png"),
                              ),
                              visible: isShow),
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
                          Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Image.asset(caliperImage),
                                iconSize: 30,
                                alignment: Alignment.center,
                                onPressed: () {
                                  setState(() {
                                    isShow = !isShow;
                                    print("IsShow :$isShow");
                                    if (isShow) {
                                      caliperImage = "assets/images/show.png";
                                    } else {
                                      caliperImage = "assets/images/hide.png";
                                    }
                                  });
                                },
                              )),
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

class ResizableWidget extends StatefulWidget {
  ResizableWidget({this.child});

  final Widget child;

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

const ballDiameter = 20.0;

class _ResizableWidgetState extends State<ResizableWidget> {
  double height = 200;
  double width = 200;

  double top = 60;
  double left = 100;

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: Container(
            height: height,
            width: width,
            // color: Colors.red[50],
            child: widget.child,
          ),
        ),
        // top left
        Positioned(
          top: top - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;
              var newHeight = height - 2 * mid;
              var newWidth = width - 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top + mid;
                left = left + mid;
              });
            },
          ),
        ),
        // top middle
        // Positioned(
        //   top: top - ballDiameter / 2,
        //   left: left + width / 2 - ballDiameter / 2,
        //   child: ManipulatingBall(
        //     onDrag: (dx, dy) {
        //       var newHeight = height - dy;
        //
        //       setState(() {
        //         height = newHeight > 0 ? newHeight : 0;
        //         top = top + dy;
        //       });
        //     },
        //   ),
        // ),
        // top right
        Positioned(
          top: top - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + (dy * -1)) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                // left = left - mid;
              });
            },
          ),
        ),
        // center right
        // Positioned(
        //   top: top + height / 2 - ballDiameter / 2,
        //   left: left + width - ballDiameter / 2,
        //   child: ManipulatingBall(
        //     onDrag: (dx, dy) {
        //       var newWidth = width + dx;
        //
        //       setState(() {
        //         width = newWidth > 0 ? newWidth : 0;
        //       });
        //     },
        //   ),
        // ),
        // bottom right
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                // left = left - mid;
              });
            },
          ),
        ),
        // bottom center
        // Positioned(
        //   top: top + height - ballDiameter / 2,
        //   left: left + width / 2 - ballDiameter / 2,
        //   child: ManipulatingBall(
        //     onDrag: (dx, dy) {
        //       var newHeight = height + dy;
        //
        //       setState(() {
        //         height = newHeight > 0 ? newHeight : 0;
        //       });
        //     },
        //   ),
        // ),
        // bottom left
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = ((dx * -1) + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
        //left center
        // Positioned(
        //   top: top + height / 2 - ballDiameter / 2,
        //   left: left - ballDiameter / 2,
        //   child: ManipulatingBall(
        //     onDrag: (dx, dy) {
        //       var newWidth = width - dx;
        //
        //       setState(() {
        //         width = newWidth > 0 ? newWidth : 0;
        //         left = left + dx;
        //       });
        //     },
        //   ),
        // ),
        // center center
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              setState(() {
                top = top + dy;
                left = left + dx;
              });
            },
          ),
        ),
      ],
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key key, this.onDrag});

  final Function onDrag;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: HexColor('#0030ff').withOpacity(0.15),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
