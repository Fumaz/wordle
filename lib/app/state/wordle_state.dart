import 'package:flutter/cupertino.dart';
import 'package:wordle/app/page/wordle_page.dart';

class WordleState extends State<WordlePage> {
  late String word = widget.word;
  final List<String> guesses = [];
  final Set<String> uselessLetters = {};
  String currentGuess = '';

  Color getBoxColor(int index, String letter) {
    if (word[index] == letter) {
      return CupertinoColors.systemGreen;
    } else if (word.contains(letter) && letter != '' && letter != ' ') {
      return CupertinoColors.systemYellow;
    } else if (letter != '' && letter != ' ') {
      uselessLetters.add(letter);
      return CupertinoColors.inactiveGray;
    } else {
      return const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.white, darkColor: CupertinoColors.black);
    }
  }

  Widget createBox(int index, String letter) {
    return SizedBox(
      width: 75,
      height: 75,
      child: Container(
        decoration: BoxDecoration(
          color: getBoxColor(index, letter),
          border: Border.all(
            color: CupertinoColors.black,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget createRow(String word) {
    List<Widget> children = [];

    for (var i = 0; i < 5; i++) {
      String letter = word.length > i ? word[i] : '';
      children.add(createBox(i, letter));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  List<Widget> createRows() {
    List<Widget> rows = [];

    for (int i = 0; i < 6; i++) {
      String guess = guesses.length > i ? guesses[i] : '';
      rows.add(createRow(guess));
    }

    return rows;
  }

  Widget createKeyboardLetter(String letter) {
    return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 10),
        minSize: 37,
        child: Text(
          letter,
          style: TextStyle(fontSize: 25),
        ),
        onPressed: () {
          setState(() {
            if (uselessLetters.contains(letter)) {
              return;
            }

            if (currentGuess.length >= 5) {
              return;
            }

            currentGuess += letter;
          });
        });
  }

  Widget createEnterKey() {
    return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 17),
        minSize: 37,
        child: Icon(CupertinoIcons.check_mark_circled_solid),
        onPressed: () {
          setState(() {
            guesses.add(currentGuess);
            currentGuess = '';
          });
        });
  }

  Widget createBackspaceKey() {
    return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 17),
        minSize: 37,
        child: Icon(CupertinoIcons.delete_left),
        onPressed: () {
          setState(() {
            if (currentGuess.isNotEmpty) {
              currentGuess = currentGuess.substring(0, currentGuess.length - 1);
            }
          });
        });
  }
  
  Widget createKeyboardPadding() {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
    );
  }

  List<Row> createKeyboard() {
    List<List<Widget>> rows = [[], [],[],[], []];

    rows[0].add(createKeyboardLetter('Q'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('W'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('E'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('R'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('T'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('Y'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('U'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('I'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('O'));
    rows[0].add(createKeyboardPadding());
    rows[0].add(createKeyboardLetter('P'));

    rows[1].add(const Padding(padding: EdgeInsets.only(top: 5)));

    rows[2].add(createKeyboardLetter('A'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('S'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('D'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('F'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('G'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('H'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('J'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('K'));
    rows[2].add(createKeyboardPadding());
    rows[2].add(createKeyboardLetter('L'));

    rows[3].add(const Padding(padding: EdgeInsets.only(top: 5)));

    rows[4].add(createEnterKey());
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('Z'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('X'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('C'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('V'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('B'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('N'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createKeyboardLetter('M'));
    rows[4].add(createKeyboardPadding());
    rows[4].add(createBackspaceKey());

    return rows
        .map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Wordle'),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [...createRows(),
            Padding(padding: EdgeInsets.only(top: 50)),
            ...createKeyboard()],
        ));
  }
}
