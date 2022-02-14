import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wordle/app/page/home_page.dart';
import 'package:wordle/app/page/wordle_page.dart';
import 'package:wordle/app/state/home_state.dart';
import 'package:wordle/language.dart';
import 'package:share_plus/share_plus.dart';


class WordleState extends State<WordlePage> {
  late String word = widget.word.toUpperCase().trim();
  final List<String> guesses = [];
  final Set<String> uselessLetters = {};
  final Set<String> allowedWords = {};
  final Map<String, int> occurrences = {};
  String currentGuess = '';
  bool disabled = false;

  @override
  void initState() {
    super.initState();
    loadAllowedWords();
  }

  void loadAllowedWords() async {
    List<String> allowed = (await DefaultAssetBundle.of(context).loadString(
        getAssetPath() + 'words')).split('\n');

    for (String word in allowed) {
      allowedWords.add(word.toUpperCase().trim());
    }

    print('Allowed words: ${allowedWords.length}');
  }

  void disableKeyboard() {
    disabled = true;
    uselessLetters.addAll({
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    });

    setState(() {});
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

  Color getBoxColor(int index, String letter, bool guessed) {
    if (!guessed) {
      return const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.white, darkColor: CupertinoColors.black);
    }

    int occurrences = this.occurrences[letter] ?? 0;
    int inWord = word.characters.where((c) => c == letter).length;

    if (word[index] == letter) {
      this.occurrences[letter] = occurrences + 1;
      return CupertinoColors.systemGreen;
    } else if (word.contains(letter) && letter != '' && letter != ' ' && occurrences < inWord) {
      this.occurrences[letter] = occurrences + 1;
      return CupertinoColors.systemYellow;
    } else if (letter != '' && letter != ' ') {
      if (!word.contains(letter)) {
        uselessLetters.add(letter);
      }

      return CupertinoColors.inactiveGray;
    } else {
      return const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.white, darkColor: CupertinoColors.black);
    }
  }

  Widget createBox(int index, String letter, bool guessed) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: getBoxColor(index, letter, guessed),
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

  Widget createRow(String word, bool guessed) {
    occurrences.clear();
    List<Widget> children = [];

    for (var i = 0; i < 5; i++) {
      String letter = word.length > i ? word[i] : '';
      children.add(createBox(i, letter, guessed));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  String createEmojiString() {
    occurrences.clear();

    String disabled = "⬛";
    String almost = "🟨";
    String correct = "🟩";

    String emoji = "Wordle 02/14/2022\n";
    for (int i = 0; i < 6; i++) {
      emoji += "\n";

      String guess = guesses.length > i ? guesses[i] : '';

      for (var j = 0; j < 5; j++) {
        String letter = word.length > j ? word[j] : '';

        int occurrences = this.occurrences[letter] ?? 0;
        int inWord = word.characters.where((c) => c == letter).length;

        if (word[j] == letter) {
          this.occurrences[letter] = occurrences + 1;
          emoji += correct;
        } else if (word.contains(letter) && letter != '' && letter != ' ' && occurrences < inWord) {
          this.occurrences[letter] = occurrences + 1;
          emoji += almost;
        } else if (letter != '' && letter != ' ') {
          if (!word.contains(letter)) {
            uselessLetters.add(letter);
          }

          emoji += disabled;
        } else {
          emoji += disabled;
        }
      }
    }

    return emoji;
  }

  List<Widget> createRows() {
    occurrences.clear();
    List<Widget> rows = [];

    for (int i = 0; i < 6; i++) {
      String guess = guesses.length > i ? guesses[i] : '';
      bool guessed = guess != '';

      if (guesses.length == i) {
        guess = currentGuess;
      }

      rows.add(createRow(guess, guessed));
    }

    return rows;
  }

  Widget createKeyboardLetter(String letter) {
    return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 10),
        minSize: 30,
        child: Text(
          letter,
          style: const TextStyle(fontSize: 20),
        ),
        onPressed: uselessLetters.contains(letter)
            ? null
            : () {
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
        minSize: 30,
        child: const Icon(CupertinoIcons.check_mark_circled_solid),
        onPressed: disabled ? null : () {
          setState(() {
            currentGuess = currentGuess.trim();
            if (currentGuess.length < 5) {
              return;
            }

            if (!allowedWords.contains(currentGuess.toUpperCase()) && currentGuess.toUpperCase() != word.toUpperCase()) {
              return;
            }

            guesses.add(currentGuess.toUpperCase());

            if (currentGuess.toUpperCase() == word.toUpperCase()) {
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
        onPressed: disabled ? null : () {
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
    List<List<Widget>> rows = [[], [], [], [], []];

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
        .map((row) =>
        Row(
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
              child: const Icon(CupertinoIcons.home), onPressed: () {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                    builder: (context) => const WordleHomePage()));
          }),
          middle: const Text('Wordle'),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...createRows(),
            const Padding(padding: EdgeInsets.only(top: 25)),
            ...createKeyboard()
          ],
        ));
  }
}
