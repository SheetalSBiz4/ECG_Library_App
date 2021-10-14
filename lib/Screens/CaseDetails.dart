import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecg/Models/CaseImageModel.dart';
import 'package:ecg/Models/CaseModel.dart';
import 'package:ecg/customs/LoaderTransparent.dart';
import 'package:ecg/util/SharedPreferenceManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/CaseModel.dart';
import '../constants.dart';
import 'AnswerImageScreen.dart';
import 'CaliperScreen.dart';
import 'WebViewScreen.dart';

class CaseDetails extends StatefulWidget {
  List<CaseModel> caseModels;
  int index;
  int pageCount;
  String level;
  int totalPages;

  CaseDetails(
      this.index, this.caseModels, this.pageCount, this.level, this.totalPages);

  @override
  _CaseDetailsState createState() {
    return _CaseDetailsState(this.index, this.caseModels, this.pageCount,
        this.level, this.totalPages);
  }
}

class _CaseDetailsState extends State<CaseDetails> {
  List<CaseModel> caseModels;
  bool previousEnable = false;
  bool nextEnable = false;
  bool isPortrait = false;
  int pageCount;
  String level;
  int totalPages;

  var _isProgressVisible = false;
  CaseModel caseModel;

  bool showAnswer = false;
  bool showReference = false;
  int index = 0;
  PhotoViewController controller;

  bool disabeScroll = false;

  bool _isShowProgress = true;

  int currentPage;

  int LIMIT_RECORD = 20;

  int totalPageCount;

  bool _isNextPageVisible = false;

  bool finishedAllCase = false;

  _CaseDetailsState(this.index, this.caseModels, this.pageCount, this.level,
      this.totalPageCount);

  @override
  Future<void> initState() {
    super.initState();
    currentPage = pageCount;
    controller = PhotoViewController();
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
      final ref = FirebaseStorage.instance
          .ref()
          .child(FB_ENV)
          .child(ENV)
          .child(FB_ATTACHMENT)
          .child(imageName);
      var url = await ref.getDownloadURL();
      CaseImageModel image = new CaseImageModel(url);
      imageUrls.add(image);
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
      final ref = FirebaseStorage.instance
          .ref()
          .child(FB_ENV)
          .child(ENV)
          .child(FB_RATIONALE_ATTACHMENT)
          .child(imageName);
      var url = await ref.getDownloadURL();
      CaseImageModel image = new CaseImageModel(url);
      imageUrls.add(image);
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
    bool isReferenceShow = true;

    String reference = caseModel?.references?.replaceAll("<p>", "");
    String supplement = caseModel?.supplement?.replaceAll("<p>", "");
    reference.replaceAll("</p>", "");
    supplement.replaceAll("</p>", "");

    if (supplement.isEmpty ||
        !supplement.startsWith('<a href="http') ||
        !supplement.startsWith('<a href="https')) {
      isSupplementShow = false;
    }

    if (reference.isEmpty ||
        !reference.startsWith('<a href="http') ||
        !reference.startsWith('<a href="https')) {
      isReferenceShow = false;
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

    if (totalCount == selectedCount) {
      setState(() {
        if (finishedAllCase) {
          _isNextPageVisible = false;
          nextEnable = false;
        } else {
          _isNextPageVisible = true;
        }
      });
    } else {
      _isNextPageVisible = false;
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
                        //_isProgressVisible? LoaderTransparent() : Container();
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CaliperScreen(
                                                caseModel?.attachemtnImages[0]
                                                    ?.serverPath)),
                                      );
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
                                          child: Text('Diagnosis:',
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(color_ffea00),
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
                                          child: Text('Rationale:',
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(color_ffea00),
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
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      // ignore: null_aware_in_condition
                                                      builder: (context) =>
                                                          // ignore: null_aware_in_condition
                                                          AnswerImageScreen(caseModel
                                                                  ?.rationaleAttachments
                                                                  ?.isNotEmpty
                                                              ? caseModel
                                                                  ?.answerImages[
                                                                      0]
                                                                  ?.serverPath
                                                              : '')),
                                                );
                                              },
                                              child: Image.asset(
                                                  'assets/images/img_sol.png',
                                                  width: 40.0,
                                                  height: 40.0),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: isReferenceShow,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 8, bottom: 8),
                                                child: Text('References:',
                                                    textScaleFactor: 1,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: HexColor(
                                                            color_ffea00),
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                              Html(
                                                  style: {
                                                    "body": Style(
                                                      padding: EdgeInsets.only(
                                                          top: 0, left: 0),
                                                      margin: EdgeInsets.only(
                                                          top: 0, left: 0),
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
                                          ),
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
                                                      top: 0, bottom: 8),
                                                  child: Text('Supplement:',
                                                      textScaleFactor: 1,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: HexColor(
                                                              color_ffea00),
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                                Html(
                                                    style: {
                                                      "body": Style(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 0,
                                                                left: 0),
                                                        margin: EdgeInsets.only(
                                                            top: 0, left: 0),
                                                        fontSize:
                                                            FontSize(12.0),
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    },
                                                    data: supplement,
                                                    onLinkTap: (String url) {
                                                      openURL(url);
                                                    }),
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
                                SizedBox(width: 50),
                                Visibility(
                                  visible: !_isNextPageVisible,
                                  child: (nextEnable
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
                                ),
                                Visibility(
                                  visible: _isNextPageVisible,
                                  child: (true
                                      ? GestureDetector(
                                          child: SvgPicture.asset(
                                            'assets/images/next_page.svg',
                                            height: 24,
                                          ),
                                          onTap: () {
                                            getCaseDataBySequence();
                                          },
                                        )
                                      : ''),
                                )
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

  getCaseDataBySequence() {
    setState(() {
      currentPage = currentPage + 1;
      _isProgressVisible = true;
    });
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FB_ENV)
        .doc(ENV)
        .collection(COLLECTION_LEVEL)
        .doc(level)
        .collection(STATS_TABLE)
        .doc('totalStats')
        .get()
        .then((value) async {
      print('value?.data()--->${value?.data()}');
      List<String> allSequence =
          new List<String>.from(value?.data()['sequence'] ?? []);
      List<String> readList = await getReadStatusList();
      if (allSequence.isNotEmpty) {
        totalPages = ((allSequence?.length / LIMIT_RECORD).ceil());
        int endLimit = allSequence?.length;
        if ((currentPage * LIMIT_RECORD) < allSequence?.length)
          endLimit = currentPage * LIMIT_RECORD;
        else
          endLimit = allSequence?.length;
        List<String> sequence =
            allSequence.sublist(((currentPage - 1) * 20), endLimit);
        for (var caseId in sequence) {
          var model = await getCase(caseId);
          if (model.isPublish) {
            if (readList.contains(model?.id)) model.isRead = true;
            caseModels.add(model);
          }
        }
        setState(() {
          Fluttertoast.showToast(msg: "More case added for you.");
          nextEnable = true;
          if (endLimit == allSequence?.length) {
            finishedAllCase = true;
          }
          _isProgressVisible = false;
        });
      } else {
        setState(() {
          _isProgressVisible = false;
        });
      }
    }).catchError((onError) async {
      print('getStats error---->${onError}');
      setState(() {
        _isProgressVisible = false;
      });
    });
  }

  Future<CaseModel> getCase(String caseID) async {
    // print('caseid------>${caseID}');
    final databaseReference = FirebaseFirestore.instance;
    var result = await databaseReference
        .collection(FB_ENV)
        .doc(ENV)
        .collection(COLLECTION_LEVEL)
        .doc(level)
        .collection(CASES_TABLE)
        .doc(caseID)
        .get();

    CaseModel model = new CaseModel();
    model.id = result.id;
    // model.createdTime = doc.data()[CREATED_TIME] ?? '';
    model.details = result.data()[DETAILS] ?? '';
    model.nextStep = result.data()[NEXTSTEP] ?? '';
    model.result = result.data()[RESULT] ?? '';
    model.references = result.data()[REFERENCES] ?? '';
    model.skillLevel = result.data()[SKILL_LEVEL] ?? '';
    model.supplement = result.data()[SUPPLEMENT] ?? '';
    model.isPublish = result.data()[IS_PUBLISH] ?? false;
    if (result.data()[DIMENSIONS] != null) {
      var hashmap = new HashMap.from(result.data()[DIMENSIONS]) ?? null;
      model.iWidth = hashmap[WIDTH]?.toDouble();
      model.iHeight = hashmap[HEIGHT]?.toDouble();
    }
    //     // model.updatedTime = doc.data()[UPDATED_TIME] ?? '';
    model.attachments = new List<String>.from(result.data()[ATTACHMENTS] ?? []);
    model.rationaleAttachments =
        new List<String>.from(result.data()[RATIONALE_ATTACHMENTS] ?? []);
    return model;
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
        height: size.height,
        child: Stack(
          children: [
            PhotoView.customChild(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    // ignore: null_aware_in_condition
                    image: NetworkImage(
                        // ignore: null_aware_in_condition
                        caseModel?.rationaleAttachments?.isNotEmpty
                            ? caseModel?.answerImages[0]?.serverPath
                            : ''),
                    // fit: BoxFit.fill,
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
