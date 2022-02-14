
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences preferences;

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();

  preferences = await SharedPreferences.getInstance();
}

String get(String key, [String defValue = '']) {
  return preferences.getString(key) ?? defValue;
}

Future<bool> set(String key, String value) async {
  return await preferences.setString(key, value);
}

Future<bool> remove(String key) async{
  return await preferences.remove(key);
}