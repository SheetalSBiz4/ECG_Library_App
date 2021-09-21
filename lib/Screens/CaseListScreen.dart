import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:ecg/Models/CaseModel.dart';
import 'package:ecg/Screens/CaseDetails.dart';
import 'package:ecg/constants.dart';
import 'package:ecg/customs/LoaderTransparent.dart';
import 'package:ecg/util/SharedPreferenceManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';

import '../constants.dart';

class CaseListScreen extends StatefulWidget {
  String level;

  CaseListScreen(this.level);

  @override
  _CaseListScreenState createState() => _CaseListScreenState(this.level);
}

class _CaseListScreenState extends State<CaseListScreen> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  int LIMIT_RECORD = 20;
  var _isVisible = false;
  var _isProgressVisible = false;
  QueryDocumentSnapshot queryDocumentSnapshot;

  // ignore: deprecated_member_use
  List<CaseModel> caseModels = new List<CaseModel>();

  bool previousEnable = false;
  bool nextEnable = false;
  bool isPortrait = true;
  int totalPages = 1;
  int currentPage = 1;
  String level;

  _CaseListScreenState(this.level);

  @override
  Future<void> initState() {
    super.initState();
    rotateToportrait();
    getCaseDataBySequence();
    // print(level);
  }

  Future<void> getCasesData() async {
    if (!await DataConnectionChecker().hasConnection) {
      Fluttertoast.showToast(msg: error_msg_no_internet);
      return;
    }
    caseModels = [];
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection(FB_ENV)
        .doc(ENV)
        .collection(COLLECTION_LEVEL)
        .doc(level)
        .collection(CASES_TABLE)
        .limit(LIMIT_RECORD + 1)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        print('docsssss-->${value?.docs?.length}');
        value.docs.forEach((doc) {
          CaseModel model = new CaseModel();
          // model.createdTime = doc.data()[CREATED_TIME] ?? '';
          model.details = doc.data()[DETAILS] ?? '';
          model.nextStep = doc.data()[NEXTSTEP] ?? '';
          model.result = doc.data()[RESULT] ?? '';
          // model.updatedTime = doc.data()[UPDATED_TIME] ?? '';
          model.attachments =
              new List<String>.from(doc.data()[ATTACHMENTS] ?? []);
          model.rationaleAttachments =
              new List<String>.from(doc.data()[RATIONALE_ATTACHMENTS] ?? []);
          caseModels.add(model);
          queryDocumentSnapshot = doc;
        });

        setState(() {
          _isProgressVisible = false;
          _isVisible = false;
          if (caseModels?.length > LIMIT_RECORD) nextEnable = true;
        });
      } else {
        setState(() {
          _isVisible = true;
          _isProgressVisible = false;
        });
      }
    }).catchError((onError) async {
      print('error in getComplaintData--->${onError}');
      setState(() {
        _isProgressVisible = false;
      });
    });
  }

  getCaseDataBySequence() {
    setState(() {
      caseModels = [];
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
      print('list--->${readList}');
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
          if (caseModels.isEmpty) {
            _isVisible = true;
            _isProgressVisible = false;
          } else {
            _isProgressVisible = false;
            _isVisible = false;
            nextEnable = (currentPage < totalPages) ? true : false;
            previousEnable = (currentPage > 1) ? true : false;
          }
        });
      } else {
        setState(() {
          _isVisible = true;
          _isProgressVisible = false;
        });
      }
    }).catchError((onError) async {
      print('getStats error---->${onError}');
      setState(() {
        _isVisible = true;
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
    //     // model.createdTime = doc.data()[CREATED_TIME] ?? '';
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

  @override
  void dispose() {
    enableRotation();
  }

  void enableRotation() {
    super.dispose();
    rotateToportrait();
  }

  void rotateToportrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    caseModels?.asMap()?.forEach((index, model) {
      model.name = 'Case ${((currentPage - 1) * 20) + index + 1}';
    });
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var bottomBarHeight = MediaQuery.of(context).padding.bottom;
    var remainingHeight =
        screenHeightExcludingToolbar(context, statusBarHeight, bottomBarHeight);
    print('remainingHeight---->${remainingHeight}');

    final double itemHeight = (size.height - kToolbarHeight) / 10;
    final double itemWidth = size.width / 2;
    return Scaffold(
        primary: true,
        appBar: AppBar(
          title: Text(level, style: TextStyle(fontSize: 18.0)),
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
                    Visibility(
                        visible: _isVisible,
                        child: Column(children: <Widget>[
                          SizedBox(height: 30),
                          Text(
                            error_msg_no_cases,
                            style: TextStyle(
                                fontSize: 13,
                                color: HexColor(color_ffffff),
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w400),
                          ),
                        ])),
                    Expanded(
                      child: GridView.builder(
                        itemCount: caseModels.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return CaseCard(
                            caseModel: caseModels[index],
                            selectedIndex: index,
                            selectedItemUUID: (int) =>
                                openCaseDetailScreen(int, context),
                            remainingHeight: remainingHeight,
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            // childAspectRatio: 5/2,
                            childAspectRatio: (itemWidth / (itemHeight - 9)),
                            crossAxisCount: 2),
                      ),
                    ),
                    if (!_isVisible)
                      Container(
                          height: kToolbarHeight,
                          width: size.width,
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    width: 1.7, color: HexColor(color_0d0e0f))),
                            color: HexColor(color_0d0e0f),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(left: 16),
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Page ${currentPage}',
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: HexColor(color_ffffff),
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        ' of ${totalPages}',
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
                              Align(
                                alignment: Alignment.center,
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
                                              loadPreviousPageCases();
                                            },
                                          )
                                        : GestureDetector(
                                            child: SvgPicture.asset(
                                              'assets/images/previous_disable.svg',
                                              height: 24,
                                            ),
                                          )),
                                    SizedBox(width: 70),
                                    (nextEnable
                                        ? GestureDetector(
                                            child: SvgPicture.asset(
                                              'assets/images/next_enable.svg',
                                              height: 24,
                                            ),
                                            onTap: () {
                                              loadNextPageCases();
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
              _isProgressVisible ? LoaderTransparent() : Container()
            ]),
          ),
        ));
    // );
  }

  void dismissPopUp() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  openCaseDetailScreen(int index, BuildContext context) {
    print('openCaseDetailScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CaseDetails(index, caseModels, currentPage)),
    ).then((value) => {getCaseDataBySequence()});
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       settings: RouteSettings(name: "/CaseDetails"),
    //       builder: (context) => CaseDetails(),
    //     ));
  }

  void changeOrientation(bool val) {
    if (isPortrait) {
      rotateToLandscape();
    } else {
      rotateToportrait();
    }
    setState(() {
      isPortrait = !isPortrait;
    });
  }

  void loadPreviousPageCases() {
    setState(() {
      if (currentPage > 0) currentPage = currentPage - 1;
      getCaseDataBySequence();
    });
  }

  void loadNextPageCases() {
    setState(() {
      currentPage = currentPage + 1;
      getCaseDataBySequence();
    });
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (MediaQuery.of(context).size.height - reducedBy) / dividedBy;
  }

  double screenHeightExcludingToolbar(
    BuildContext context,
    double statusBarHeight,
    double bottomBarHeight,
  ) {
    return (((MediaQuery.of(context).size.height) -
        (kToolbarHeight + 42 + 60 + statusBarHeight + bottomBarHeight)));
  }
}

class CaseCard extends StatelessWidget {
  const CaseCard(
      {Key key,
      this.caseModel,
      this.selectedIndex,
      this.selectedItemUUID,
      this.remainingHeight})
      : super(key: key);
  final CaseModel caseModel;
  final int selectedIndex;
  final double remainingHeight;
  final Function(int) selectedItemUUID;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // print('screenHeightExcludingToolbar---${remainingHeight}');
    double itemHeight = remainingHeight / 14;
    // print('item height--${itemHeight}');
    double textSize = ((itemHeight) / 4.5);
    if (textSize < 14) textSize = 14;
    if (textSize > 17) textSize = 17;
    // print('item text size--${textSize}');
    return Stack(children: <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: itemHeight,
                width: size.width,
                decoration: BoxDecoration(
                    color: HexColor('#0d0e0f'),
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(color: HexColor("#1d1e20"))),
                // padding: EdgeInsets.all(15),
                child: InkWell(
                  onTap: () {
                    selectedItemUUID(selectedIndex);
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: new Text(
                            caseModel.name,
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: caseModel?.isRead
                                    ? HexColor(color_read)
                                    : Colors.white,
                                fontSize: textSize,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
