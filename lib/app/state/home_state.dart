import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:wordle/app/page/home_page.dart';
import 'package:wordle/app/page/wordle_page.dart';
import 'package:wordle/language.dart';
import 'package:wordle/settings.dart' as settings;

class WordleHomeState extends State<WordleHomePage> {
  String _selectedCategory = '';

  Widget selector(IconData icon, String label, Color color) {
    return GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border: Border.all(
                  width: 2.0,
                  color: color.withAlpha(_selectedCategory == label ? 255 : 0)),
              borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            children: [
              Icon(icon, size: 100, color: color),
              Text(label, style: TextStyle(fontSize: 25, color: color)),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        });
  }

  Future<List<String>> getSolutions() async {
    return (await DefaultAssetBundle.of(context)
            .loadString(getAssetPath() + 'solutions'))
        .split('\n');
  }

  void chooseDaily() {
    getSolutions().then((solutions) {
      int seed =
          DateTime.now().year ^ DateTime.now().month ^ DateTime.now().day;
      Random random = Random(seed);

      int index = random.nextInt(solutions.length);
      String solution = solutions[index];

      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => WordlePage(word: solution.toUpperCase())));
    });
  }

  void chooseRandom() {
    getSolutions().then((solutions) {
      int seed = DateTime.now().millisecondsSinceEpoch;
      Random random = Random(seed);

      int index = random.nextInt(solutions.length);
      String solution = solutions[index];

      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => WordlePage(word: solution.toUpperCase())));
    });
  }

  void pickLanguage() {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(title: Text("Pick a language"), actions: [
            for (Language language in Language.values)
              CupertinoDialogAction(
                child: Text(getEmoji(language)),
                onPressed: () {
                  Navigator.pop(context);
                  settings
                      .set("language", getDisplayName(language))
                      .then((value) {
                    setState(() {});
                  });
                },
              )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    Language language = getCurrentLanguage();

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
            child: Text(getEmoji(language), style: TextStyle(fontSize: 35)),
            onTap: () {
              pickLanguage();
            },
          ),
          middle: Text('Wordle'),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selector(CupertinoIcons.calendar, 'Daily',
                    CupertinoColors.systemYellow),
                Padding(padding: const EdgeInsets.all(20.0)),
                selector(CupertinoIcons.qrcode, 'Random',
                    CupertinoColors.systemBlue),
              ],
            ),
            Padding(padding: const EdgeInsets.all(35.0)),
            CupertinoButton.filled(
              child: Text('Continue'),
              onPressed: () {
                if (_selectedCategory == 'Daily') {
                  chooseDaily();
                } else if (_selectedCategory == 'Random') {
                  chooseRandom();
                }
              },
            ),
          ],
        ));
  }
}
