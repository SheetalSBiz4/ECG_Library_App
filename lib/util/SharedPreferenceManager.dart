import 'package:ecg/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getReadStatusList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> readList = prefs.getStringList(READ_LIST) ?? [];
  return readList;
}

Future saveReadStatus(String caseID) async {
  List<String> readList = await getReadStatusList();
  readList.add(caseID);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(READ_LIST, readList);
}
