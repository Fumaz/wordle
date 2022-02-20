import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wordle/app/page/home_page.dart';
import 'package:wordle/app/page/wordle_page.dart';
import 'package:wordle/app/state/home_state.dart';
import 'package:wordle/language.dart';
import 'package:share_plus/share_plus.dart';

enum GuessState { correct, wrongPosition, wrong }

class WordleState extends State<WordlePage> {
  late String word = widget.word.toUpperCase().trim();
  final List<String> guesses = [];
  final List<List<GuessState>> guessesResults = [];
  final Map<String, GuessState> keyboardHints = {};
  final Set<String> allowedWords = {};
  String currentGuess = '';
  bool disabled = false;

  @override
  void initState() {
    super.initState();
    loadAllowedWords();
  }

  void loadAllowedWords() async {
    List<String> allowed = (await DefaultAssetBundle.of(context)
            .loadString(getAssetPath() + 'words'))
        .split('\n');

    for (String word in allowed) {
      allowedWords.add(word.toUpperCase().trim());
    }
  }

  void disableKeyboard() {
    setState(() {
      disabled = true;
    });
  }

  void showWinDialog() {
    disableKeyboard();

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('You win!'),
            content: Text('The word was $word'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('Home'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const WordleHomePage()));
                },
              ),
              CupertinoDialogAction(
                child: const Text('Share'),
                onPressed: () {
                  Navigator.pop(context);
                  Share.share(createEmojiString(), subject: 'Wordle');
                },
              ),
            ],
          );
        });
  }

  void showLoseDialog() {
    disableKeyboard();

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('You lose!'),
            content: Text('The word was $word'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('Home'),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const WordleHomePage()));
                },
              ),
              CupertinoDialogAction(
                child: const Text('Share'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Color getBoxColor(int rowIndex, int letterIndex) {
    if (rowIndex >= guessesResults.length) {
      return const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.white, darkColor: CupertinoColors.black);
    }

    if (guessesResults[rowIndex][letterIndex] == GuessState.correct) {
      return CupertinoColors.systemGreen;
    } else if (guessesResults[rowIndex][letterIndex] ==
        GuessState.wrongPosition) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.inactiveGray;
    }
  }

  Color getKeyColor(String letter) {
    if (!keyboardHints.containsKey(letter)) {
      return CupertinoTheme.of(context).primaryColor;
    }

    if (keyboardHints[letter] == GuessState.correct) {
      return CupertinoColors.systemGreen;
    } else if (keyboardHints[letter] == GuessState.wrongPosition) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.inactiveGray;
    }
  }

  Widget createBox(int index, String letter, int rowIndex) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: getBoxColor(rowIndex, index),
          border: Border.all(
            color: CupertinoColors.black,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget createRow(String word, int rowIndex) {
    List<Widget> children = [];

    for (var i = 0; i < 5; i++) {
      String letter = word.length > i ? word[i] : '';
      children.add(createBox(i, letter, rowIndex));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  String createEmojiString() {
    String emoji = "Wordle 02/14/2022 (${guessesResults.length}/6)\nwordle.fumaz.dev\n";
    var resultsMap = {
      GuessState.correct: "🟩",
      GuessState.wrongPosition: "🟨",
      GuessState.wrong: "⬛"
    };
    for (int i = 0; i < guessesResults.length; i++) {
      emoji += "\n";

      for (var j = 0; j < 5; j++) {
        // null coalescing is required by the language but should never happen
        emoji += resultsMap[guessesResults[i][j]] ?? '?';
      }
    }

    return emoji;
  }

  List<Widget> createRows() {
    List<Widget> rows = [];

    for (int i = 0; i < 6; i++) {
      String guess = guesses.length > i ? guesses[i] : '';

      if (guesses.length == i) {
        guess = currentGuess;
      }

      rows.add(createRow(guess, i));
    }

    return rows;
  }

  Widget createKeyboardLetter(String letter) {
    return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 10),
        minSize: 30,
        child: Text(
          letter,
          style: const TextStyle(fontSize: 20),
        ),
        color: getKeyColor(letter),
        onPressed: disabled
            ? null
            : () {
                setState(() {
                  if (currentGuess.length >= 5) {
                    return;
                  }
                  currentGuess += letter;
                });
              });
  }

  List<GuessState> computeGuessResults(String currentGuess, String solution) {
    // compute the color of each character in the guess
    var foundGuess = [for (var i = 0; i < 5; i++) false];
    var foundSol = [for (var i = 0; i < 5; i++) false];
    var rightPos = [for (var i = 0; i < 5; i++) false];
    var wrongPos = [for (var i = 0; i < 5; i++) false];

    // first see what character are correct
    for (var i = 0; i < 5; i++) {
      if (currentGuess[i] == solution[i]) {
        foundSol[i] = true;
        foundGuess[i] = true;
        rightPos[i] = true;
      }
    }

    // next find the characters which are correct but in the wrong position
    for (var i = 0; i < 5; i++) {
      if (!foundGuess[i]) {
        for (var j = 0; j < 5; j++) {
          if (!foundSol[j] && currentGuess[i] == solution[j]) {
            wrongPos[i] = true;
            foundGuess[i] = true;
            foundSol[j] = true;
          }
        }
      }
    }

    // choose the colours for each letter
    List<GuessState> guessResults = [];
    for (var i = 0; i < 5; i++) {
      if (rightPos[i]) {
        guessResults.add(GuessState.correct);
      } else if (wrongPos[i]) {
        guessResults.add(GuessState.wrongPosition);
      } else {
        guessResults.add(GuessState.wrong);
      }
    }

    return guessResults;
  }

  Widget createEnterKey() {
    return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 17),
        minSize: 30,
        child: const Icon(CupertinoIcons.check_mark_circled_solid),
        onPressed: disabled
            ? null
            : () {
                setState(() {
                  var solution = word.toUpperCase();
                  currentGuess = currentGuess.trim().toUpperCase();
                  if (currentGuess.length < 5) {
                    return;
                  }

                  if (!allowedWords.contains(currentGuess) &&
                      currentGuess != solution) {
                    return;
                  }

                  guesses.add(currentGuess);

                  var guessResults =
                      computeGuessResults(currentGuess, solution);
                  guessesResults.add(guessResults);
                  const hintValue = {
                    GuessState.correct: 2,
                    GuessState.wrongPosition: 1,
                    GuessState.wrong: 0
                  };
                  for (var i = 0; i < 5; i++) {
                    var letter = currentGuess[i];

                    var currHintValue = hintValue[keyboardHints[letter]] ?? -1;
                    var newHintValue = hintValue[guessResults[i]] ?? -1;

                    if (newHintValue > currHintValue) {
                      keyboardHints[letter] = guessResults[i];
                    }
                  }

                  if (currentGuess == solution) {
                    showWinDialog();
                  } else if (guesses.length >= 6) {
                    showLoseDialog();
                  }

                  currentGuess = '';
                });
              });
  }

  Widget createBackspaceKey() {
    return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 17),
        minSize: 30,
        child: const Icon(CupertinoIcons.delete_left),
        onPressed: disabled
            ? null
            : () {
                setState(() {
                  if (currentGuess.isNotEmpty) {
                    currentGuess =
                        currentGuess.substring(0, currentGuess.length - 1);
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
    const keyboardLines = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"];
    List<List<Widget>> rows = [[], [], [], [], []];

    rows[4].add(createEnterKey());
    for (var lineIdx = 0; lineIdx < 3; lineIdx += 1) {
      for (var chr in keyboardLines[lineIdx].split('')) {
        if (rows[lineIdx * 2].isNotEmpty) {
          rows[lineIdx * 2].add(createKeyboardPadding());
        }
        rows[lineIdx * 2].add(createKeyboardLetter(chr));
      }
    }

    rows[1].add(const Padding(padding: EdgeInsets.only(top: 5)));
    rows[3].add(const Padding(padding: EdgeInsets.only(top: 5)));

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
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoButton(
              child: const Icon(CupertinoIcons.home),
              onPressed: () {
                Navigator.of(context).pushReplacement(CupertinoPageRoute(
                    builder: (context) => const WordleHomePage()));
              }),
          middle: const Text('Wordle'),
        ),
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...createRows(),
            const Padding(padding: EdgeInsets.only(top: 25)),
            ...createKeyboard()
          ],
        )));
  }
}
