import 'package:flutter/cupertino.dart';
import 'package:wordle/app/app.dart';
import 'package:wordle/settings.dart';

void main() {
  setup().then((value) => runApp(const WordleApp()));
}