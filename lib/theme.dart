import 'package:flutter/cupertino.dart';

final lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(color: CupertinoColors.black),
        actionTextStyle: TextStyle(color: CupertinoColors.black),
    ),
);

final darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(color: CupertinoColors.white),
        actionTextStyle: TextStyle(color: CupertinoColors.black),
    ),
);
