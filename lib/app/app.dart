import 'package:flutter/cupertino.dart';

import 'page/home_page.dart';

class WordleApp extends StatelessWidget {
  const WordleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPink
      ),
      home: WordleHomePage(),
    );
  }

}