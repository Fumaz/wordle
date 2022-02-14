import 'package:flutter/cupertino.dart';
import 'package:wordle/app/state/wordle_state.dart';

class WordlePage extends StatefulWidget {

  final String word;

  const WordlePage({Key? key, required this.word}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WordleState();
  }

}