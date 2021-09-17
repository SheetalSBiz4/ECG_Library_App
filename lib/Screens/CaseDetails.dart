import 'package:ecg/Models/CaseImageModel.dart';
import 'package:ecg/Models/CaseModel.dart';
import 'package:ecg/util/SharedPreferenceManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/CaseModel.dart';
import '../constants.dart';
import 'WebViewScreen.dart';

class CaseDetails extends StatefulWidget {
  List<CaseModel> caseModels;
  int index;
  int pageCount;

  CaseDetails(this.index, this.caseModels, this.pageCount);

  @override
  _CaseDetailsState createState() {
    return _CaseDetailsState(this.index, this.caseModels, this.pageCount);
  }
}

class _CaseDetailsState extends State<CaseDetails> {
  List<CaseModel> caseModels;
  bool previousEnable = false;
  bool nextEnable = false;
  bool isPortrait = false;
  int pageCount;

  var _isProgressVisible = false;
  CaseModel caseModel;

  bool showAnswer = false;
  bool showReference = false;
  int index = 0;
  PhotoViewController controller;

  bool disabeScroll = false;

  bool _isShowProgress = true;

  _CaseDetailsState(this.index, this.caseModels, this.pageCount);

  @override
  Future<void> initState() {
    super.initState();
    controller = PhotoViewController();
    // print("caseModels >>>>>>>>>>>${caseModels.length}");
    // print("pageCount >>>>>>>>>>>${pageCount}");
    rotateToLandscape();
    getImagesFromFB();
    getAnswerImageFromFB();
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
    if (url.startsWith('http') || url.startsWith('https')) {
      if (canLaunch(url) != null) launch(url);
    } else {
      Fluttertoast.showToast(msg: "Unable to open due to invalid url");
    }
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
        _isShowProgress = false;
        caseModel.attachemtnImages = imageUrls;
      });
    });
  }

  getAnswerImageFromFB() async {
    controller.dispose();
    controller = PhotoViewController();
    setState(() {
      nextEnable = (index + 1) < caseModels?.length ? true : false;
      previousEnable = index > 0 ? true : false;
      caseModel = caseModels[index];
    });
    await saveReadStatus(caseModel.id);
    List<CaseImageModel> imageUrls = [];
    caseModel?.rationaleAttachments?.forEach((imageName) async {
      // print('Image NAme---${imageName}');
      final ref = FirebaseStorage.instance
          .ref()
          .child(FB_ENV)
          .child(ENV)
          .child(FB_RATIONALE_ATTACHMENT)
          .child(imageName);
      var url = await ref.getDownloadURL();
      // print(url);
      CaseImageModel image = new CaseImageModel(url);
      imageUrls.add(image);
      // print('answerImages---->${imageUrls}');
      setState(() {
        caseModel.answerImages = imageUrls;
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
    Size size = MediaQuery.of(context).size;
    var bottomBarHeight = MediaQuery.of(context).padding.bottom;
    bool isSupplementShow = true;
    bool isAnswerImageShow = true;
    // print('size------>${size.width}-------${size.height}');
    // print('ratio------>${caseModel.iHeight / caseModel.iWidth}-------');
    // print(
    //     'Image height------>${size.width * (caseModel.iHeight / caseModel.iWidth)}-------');
    String reference = caseModel?.references?.replaceAll("<p>", "");
    String supplement = caseModel?.supplement?.replaceAll("<p>", "");

    if (supplement.isEmpty) {
      isSupplementShow = false;
    }

    if (caseModel.rationaleAttachments.isEmpty ||
        caseModel.rationaleAttachments[0].isEmpty) {
      isAnswerImageShow = false;
    }

    var selectedCount;
    if (pageCount > 1) {
      selectedCount = '${pageCount * 10 + index + 1}';
    } else {
      selectedCount = '${index + 1}';
    }

    var totalCount;
    if (pageCount > 1) {
      totalCount = '${pageCount * 10 + caseModels?.length}';
    } else {
      totalCount = '${caseModels?.length}';
    }

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
              activeTrackColor: HexColor(color_676767),
              inactiveThumbColor: HexColor(color_ffffff),
              inactiveTrackColor: HexColor(color_676767),
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
                                        color: HexColor(color_ffffff),
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 17),
                                  color: HexColor(color_theme),
                                  width: size.width,
                                  height: size.width *
                                      (caseModel.iHeight / caseModel.iWidth),
                                  child: InkWell(
                                    // child: Container(
                                    //   child: FadeInImage.assetNetwork(
                                    //     placeholder: '',
                                    //     // ignore: null_aware_in_condition
                                    //     image: caseModel
                                    //         ?.attachemtnImages?.isNotEmpty
                                    //         ? caseModel?.attachemtnImages[0]
                                    //         ?.serverPath
                                    //         : '',
                                    //     fit: BoxFit.fill,
                                    //   ),
                                    // ),

                                    child: Container(
                                      child: Visibility(
                                          visible: _isShowProgress,
                                          child: Center(
                                              child: SizedBox(
                                                  width: size.width,
                                                  height: size.width *
                                                      (caseModel.iHeight /
                                                          caseModel.iWidth),
                                                  child: Image.asset(
                                                    'assets/placeholder.png',
                                                    fit: BoxFit.fill,
                                                  )))),
                                      decoration: BoxDecoration(
                                        color: Colors.white30,
                                        image: DecorationImage(
                                          // ignore: null_aware_in_condition
                                          image: NetworkImage(caseModel
                                                  ?.attachemtnImages?.isNotEmpty
                                              ? caseModel?.attachemtnImages[0]
                                                  ?.serverPath
                                              : ''),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      Fluttertoast.showToast(
                                          msg: " Caliper screen coming soon...  ");
                                      // await showDialog(
                                      //     context: context,
                                      //     barrierDismissible: true,
                                      //     builder: (_) =>
                                      //         ImageDialog(caseModel)
                                      // );
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
                                              color: HexColor(color_ffffff))),
                                      onPressed: () {
                                        setState(() {
                                          showAnswer = true;
                                        });
                                      },
                                      child: Text('Show Answer',
                                          textScaleFactor: 1,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: HexColor(color_ffffff),
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
                                          child: Text('DIAGNOSIS:',
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(color_ffffff),
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        Text(caseModel?.result,
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: HexColor(color_ffffff),
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400)),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 15, bottom: 8),
                                          child: Text('RATIONALE:',
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(color_ffffff),
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        Text(caseModel?.nextStep,
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: HexColor(color_ffffff),
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w400)),
                                        Visibility(
                                          visible: isAnswerImageShow,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: 15, bottom: 8),
                                            child: InkWell(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    builder: (_) =>
                                                        AnswerImageDialog(
                                                            caseModel));
                                              },
                                              child: Image.asset(
                                                  'assets/images/img_sol.png',
                                                  width: 50.0,
                                                  height: 50.0),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 8, bottom: 8),
                                              child: Text('REFERENCES:',
                                                  textScaleFactor: 1,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: HexColor(
                                                          color_ffffff),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                openURL(reference);
                                              },
                                              child: new Text(reference,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: "Montserrat",
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                            visible: isSupplementShow,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 15, bottom: 8),
                                                  child: Text('SUPPLEMENT:',
                                                      textScaleFactor: 1,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: HexColor(
                                                              color_ffffff),
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    openURL(supplement);
                                                  },
                                                  child: new Text(supplement,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily:
                                                            "Montserrat",
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      )),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // childSize: Size(size.width, size.height * 0.6),
                      backgroundDecoration:
                          BoxDecoration(color: HexColor(color_theme)),
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
                                width: 1.7, color: HexColor('#ff1d1e20'))),
                        color: HexColor(color_0d0e0f),
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
                                    // '${pageCount * 10 + index + 1}',
                                    selectedCount,
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    // ' of ${pageCount * 10 + caseModels?.length}',
                                    ' of $totalCount',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(color_444444),
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
      getAnswerImageFromFB();
    });
  }

  void loadPreviousCase() {
    setState(() {
      if (index > 0) index = index - 1;
      caseModel = caseModels[index];
      showAnswer = false;
      showReference = false;
      getImagesFromFB();
      getAnswerImageFromFB();
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

// ignore: must_be_immutable
class AnswerImageDialog extends StatelessWidget {
  int index;
  String url;
  CaseModel caseModel;

  AnswerImageDialog(this.caseModel);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      child: Container(
        width: size.width,
        height: size.width * (caseModel.iHeight / caseModel.iWidth),
        child: Stack(
          children: [
            PhotoView.customChild(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                  image: DecorationImage(
                    // ignore: null_aware_in_condition
                    image: NetworkImage(
                        // ignore: null_aware_in_condition
                        caseModel?.rationaleAttachments?.isNotEmpty
                            ? caseModel?.answerImages[0]?.serverPath
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
          ],
        ),
      ),
    );
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
                    // ignore: null_aware_in_condition
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
              child: Image.asset("assets/images/blank_image.png"),
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
