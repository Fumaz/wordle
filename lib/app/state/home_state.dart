import 'package:flutter/cupertino.dart';
import 'package:wordle/app/page/home_page.dart';
import 'package:wordle/app/page/wordle_page.dart';

class WorldeHomeState extends State<WordleHomePage> {
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
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
                Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(builder: (context) => const WordlePage(word: "CYNIC")));
              },
            ),
          ],
        ));
  }
}
