
class CaseImageModel {
  String _serverPath = '';

  CaseImageModel(this._serverPath);

  String get serverPath => _serverPath;

  set serverPath(String value) {
    _serverPath = value;
  }
}