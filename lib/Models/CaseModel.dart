import 'package:ecg/Models/CaseImageModel.dart';

class CaseModel {
  String _id = '';
  String _name = '';
  String _createdTime;
  String _details;
  String _nextStep;
  String _result;
  String _references;
  String _updatedTime;
  double _width = 1;
  double _height = 1;
  List<String> _attachments;
  List<CaseImageModel> _attachemtnImages = [];
  bool _isRead = false;

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  bool get isRead => _isRead;

  set isRead(bool value) {
    _isRead = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get createdTime => _createdTime;

  set createdTime(String value) {
    _createdTime = value;
  }

  String get details => _details;

  set details(String value) {
    _details = value;
  }

  String get nextStep => _nextStep;

  set nextStep(String value) {
    _nextStep = value;
  }

  String get result => _result;

  set result(String value) {
    _result = value;
  }

  String get references => _references;

  set references(String value) {
    _references = value;
  }

  String get updatedTime => _updatedTime;

  set updatedTime(String value) {
    _updatedTime = value;
  }

  List<String> get attachments => _attachments;

  set attachments(List<String> value) {
    _attachments = value;
  }

  List<CaseImageModel> get attachemtnImages => _attachemtnImages;

  set attachemtnImages(List<CaseImageModel> value) {
    _attachemtnImages = value;
  }

  double get iWidth => _width;

  set iWidth(double value) {
    _width = value;
  }

  double get iHeight => _height;

  set iHeight(double value) {
    _height = value;
  }
}
