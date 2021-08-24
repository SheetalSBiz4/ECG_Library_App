import 'package:ecg/Models/CaseImageModel.dart';
import 'package:ecg/Models/CaseModel.dart';
import 'package:ecg/util/SharedPreferenceManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/CaseModel.dart';
import '../constants.dart';
import 'WebViewScreen.dart';

class CaseDetails extends StatefulWidget {
  List<CaseModel> caseModels;
  int index;

  CaseDetails(this.index, this.caseModels);

  @override
  _CaseDetailsState createState() {
    return _CaseDetailsState(this.index, this.caseModels);
  }
}

class _CaseDetailsState extends State<CaseDetails> {
  List<CaseModel> caseModels;
  bool previousEnable = false;
  bool nextEnable = false;
  bool isPortrait = false;

  var _isVisible = false;
  var _isProgressVisible = false;
  CaseModel caseModel;

  bool showAnswer = false;
  bool showReference = false;
  int index = 0;
  PhotoViewController controller;

  bool disabeScroll = false;

  _CaseDetailsState(this.index, this.caseModels);

  @override
  Future<void> initState() {
    super.initState();
    controller = PhotoViewController();
    rotateToLandscape();
    getImagesFromFB();
  }

  @override
  void dispose() {
    super.dispose();
    rotateToPortrait();
  }

  void rotateToPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void openURL(url) {
    if (canLaunch(url) != null) launch(url);
    // openWebViewScreen(url);
  }

  openWebViewScreen(url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url)),
    );
  }

  void rotateToLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  getImagesFromFB() async {
    controller.dispose();
    controller = PhotoViewController();
    setState(() {
      nextEnable = (index + 1) < caseModels?.length ? true : false;
      previousEnable = index > 0 ? true : false;
      caseModel = caseModels[index];
    });
    await saveReadStatus(caseModel.id);
    List<CaseImageModel> imageUrls = [];
    caseModel?.attachments?.forEach((imageName) async {
      // print('Image NAme---${imageName}');
      final ref = FirebaseStorage.instance
          .ref()
          .child(FB_ENV)
          .child(ENV)
          .child(FB_ATTACHMENT)
          .child(imageName);
      var url = await ref.getDownloadURL();
      // print(url);
      CaseImageModel image = new CaseImageModel(url);
      imageUrls.add(image);
      // print('imageUrls---->${imageUrls}');
      setState(() {
        caseModel.attachemtnImages = imageUrls;
      });
    });
  }

  void changeOrientation(bool val) {
    if (isPortrait) {
      rotateToLandscape();
    } else {
      rotateToPortrait();
    }
    setState(() {
      isPortrait = !isPortrait;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('disabeScroll---${disabeScroll}');
    Size size = MediaQuery.of(context).size;
    var bottomBarHeight = MediaQuery.of(context).padding.bottom;
    // print('bottomBarHeight---->${bottomBarHeight}');
    print('size------>${size.width}-------${size.height}');
    print('ratio------>${caseModel.iHeight / caseModel.iWidth}-------');
    print(
        'Image height------>${size.width * (caseModel.iHeight / caseModel.iWidth)}-------');
    String reference = caseModel?.references?.replaceAll("<p>", "");
    // print('teststt ${reference}');
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          title: Text(caseModel?.name),
          backgroundColor: primaryColor,
          brightness: Brightness.dark,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            Switch(
              onChanged: changeOrientation,
              value: !isPortrait,
              activeColor: HexColor(color_ffffff),
              activeTrackColor: HexColor(color_dc3f4dff),
              inactiveThumbColor: HexColor(color_ffffff),
              inactiveTrackColor: HexColor(color_dc3f4dff),
            ),
            (isPortrait
                ? IconButton(
                    icon: Image.asset("assets/images/portrait.png"),
                    onPressed: () {},
                  )
                : IconButton(
                    icon: Image.asset("assets/images/landscape.png"),
                    onPressed: () {},
                  )),
          ]),
      body: Container(
        color: HexColor(color_ffffff),
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
                color: HexColor(color_ffffff)),
            child: Container(
              child: Column(
                children: <Widget>[
                  Visibility(
                      visible: _isProgressVisible,
                      child: Column(children: <Widget>[
                        SizedBox(height: 30),
                        CircularProgressIndicator()
                      ])),
                  Expanded(
                    child: PhotoView.customChild(
                      child: Container(
                        child: SingleChildScrollView(
                          physics: disabeScroll
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    caseModel?.details,
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(color_333333),
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 17),
                                  color: Colors.white,
                                  width: size.width,
                                  height: size.width *
                                      (caseModel.iHeight / caseModel.iWidth),
                                  child: InkWell(
                                    child: Container(
                                      // decoration: BoxDecoration(
                                      //   color: Colors.white,
                                      //   image: DecorationImage(
                                      //     image: NetworkImage(caseModel
                                      //             ?.attachemtnImages?.isNotEmpty
                                      //         ? caseModel?.attachemtnImages[0]
                                      //             ?.serverPath
                                      //         : ''),
                                      //     fit: BoxFit.fill,
                                      //   ),
                                      //   // border: Border.all(
                                      //   //   color: Colors.white,
                                      //   //   width: 1.0,
                                      //   // ),
                                      //   // borderRadius: BorderRadius.circular(5.0),
                                      // ),

                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'placeholder.png',
                                        image: caseModel
                                                ?.attachemtnImages?.isNotEmpty
                                            ? caseModel?.attachemtnImages[0]
                                                ?.serverPath
                                            : '',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) =>
                                              ImageDialog(caseModel));
                                    },
                                  ),
                                  // childSize: Size(size.width, size.height * 0.6),
                                ),
                                if (!showAnswer)
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7.0),
                                          side: BorderSide(
                                              color: HexColor(color_dc3f4dff))),
                                      onPressed: () {
                                        setState(() {
                                          showAnswer = true;
                                        });
                                      },
                                      child: Text('Show Answer',
                                          textScaleFactor: 1,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: HexColor(color_dc3f4dff),
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                if (showAnswer)
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom: 8, top: 20),
                                          child: Text('Diagnosis:',
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      HexColor(color_dc3f4dff),
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                        Text(caseModel?.result,
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: HexColor(color_333333),
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400)),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 8),
                                          child: Text('Rationale:',
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      HexColor(color_dc3f4dff),
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                        Text(caseModel?.nextStep,
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: HexColor(color_333333),
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400)),
                                        if (!showReference)
                                          Container(
                                            margin: EdgeInsets.only(top: 0),
                                            child: FlatButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          7.0),
                                                  side: BorderSide(
                                                      color: HexColor(
                                                          color_dc3f4dff))),
                                              onPressed: () {
                                                setState(() {
                                                  showReference = true;
                                                });
                                              },
                                              minWidth: 0,
                                              height: 0,
                                              padding: EdgeInsets.all(5),
                                              child: Text('References',
                                                  textScaleFactor: 1,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: HexColor(
                                                          color_dc3f4dff),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        if (showReference)
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 9),
                                                child: Text('References:',
                                                    textScaleFactor: 1,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: HexColor(
                                                            color_dc3f4dff),
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ),
                                              Html(
                                                  style: {
                                                    "body": Style(
                                                      padding: EdgeInsets.only(
                                                          top: 0, left: 0),
                                                      margin: EdgeInsets.only(
                                                          top: 8, left: 0),
                                                      fontSize: FontSize(13.0),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  },
                                                  data: reference,
                                                  onLinkTap: (String url) {
                                                    openURL(url);
                                                  }),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // childSize: Size(size.width, size.height * 0.6),
                      backgroundDecoration: BoxDecoration(color: Colors.white),
                      // customSize: MediaQuery.of(context).size,
                      enableRotation: false,
                      scaleStateChangedCallback: onScaleStateChangedCallback,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                      initialScale: PhotoViewComputedScale.contained,
                      // basePosition: Alignment.center,
                    ),
                  ),
                  Container(
                      height: (41 + bottomBarHeight),
                      padding: EdgeInsets.only(bottom: bottomBarHeight),
                      width: size.width,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                width: 1.7, color: HexColor(color_e6e6e6ff))),
                        color: HexColor(color_ffffff),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(left: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  child: SvgPicture.asset(
                                    'assets/images/back_to_list.svg',
                                    height: 16,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${index + 1}',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: primaryColor,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    ' of ${caseModels?.length}',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(color_afafafff),
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: 17),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (previousEnable
                                    ? GestureDetector(
                                        child: SvgPicture.asset(
                                          'assets/images/previous_enable.svg',
                                          height: 24,
                                        ),
                                        onTap: () {
                                          loadPreviousCase();
                                        },
                                      )
                                    : GestureDetector(
                                        child: SvgPicture.asset(
                                          'assets/images/previous_disable.svg',
                                          height: 24,
                                        ),
                                      )),
                                SizedBox(width: 53),
                                (nextEnable
                                    ? GestureDetector(
                                        child: SvgPicture.asset(
                                          'assets/images/next_enable.svg',
                                          height: 24,
                                        ),
                                        onTap: () {
                                          loadNextCase();
                                        },
                                      )
                                    : GestureDetector(
                                        child: SvgPicture.asset(
                                          'assets/images/next_disable.svg',
                                          height: 24,
                                        ),
                                      )),
                              ],
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loadNextCase() {
    setState(() {
      index = index + 1;
      caseModel = caseModels[index];
      showAnswer = false;
      showReference = false;
      getImagesFromFB();
    });
  }

  void loadPreviousCase() {
    setState(() {
      if (index > 0) index = index - 1;
      caseModel = caseModels[index];
      showAnswer = false;
      showReference = false;
      getImagesFromFB();
    });
  }

  void onScaleStateChangedCallback(PhotoViewScaleState value) {
    print('onScaleStateChangedCallback${value}');
    if (value == PhotoViewScaleState.zoomedIn) {
      setState(() {
        disabeScroll = true;
      });
    } else {
      setState(() {
        disabeScroll = false;
      });
    }
  }
}

class ImageDialog extends StatelessWidget {
  int index;
  String url;
  CaseModel caseModel;

  ImageDialog(this.caseModel);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print('Alert size------>${size.width}-------${size.height}');
    print('Alert ratio------>${caseModel.iHeight / caseModel.iWidth}-------');
    print(
        'Alert Image height------>${size.width * (caseModel.iHeight / caseModel.iWidth)}-------');
    return Dialog(
      child: Container(
        width: size.width,
        height: size.width * (caseModel.iHeight / caseModel.iWidth),
        child: Stack(
          children: [
            PhotoView.customChild(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: NetworkImage(caseModel?.attachemtnImages?.isNotEmpty
                        ? caseModel?.attachemtnImages[0]?.serverPath
                        : ''),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // childSize: Size(size.width, size.height * 0.6),
              backgroundDecoration: BoxDecoration(color: Colors.white),
              // customSize: MediaQuery.of(context).size,
              enableRotation: false,

              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              initialScale: PhotoViewComputedScale.contained,
              // basePosition: Alignment.center,
            ),
            ResizebleWidget(
              child:Image.asset("assets/images/blank_image.png"),
              // child: Text(
              //   '''
              //
              //
              //                                             ''',
              // ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResizebleWidget extends StatefulWidget {
  ResizebleWidget({this.child});

  final Widget child;

  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

const ballDiameter = 20.0;

class _ResizebleWidgetState extends State<ResizebleWidget> {
  double height = 200;
  double width = 200;

  double top = 0;
  double left = 0;

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
        Positioned(
          top: top - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newHeight = height - dy;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                top = top + dy;
              });
            },
          ),
        ),
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
                left = left - mid;
              });
            },
          ),
        ),
        // center right
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newWidth = width + dx;

              setState(() {
                width = newWidth > 0 ? newWidth : 0;
              });
            },
          ),
        ),
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
                left = left - mid;
              });
            },
          ),
        ),
        // bottom center
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newHeight = height + dy;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
              });
            },
          ),
        ),
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
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newWidth = width - dx;

              setState(() {
                width = newWidth > 0 ? newWidth : 0;
                left = left + dx;
              });
            },
          ),
        ),
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
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
