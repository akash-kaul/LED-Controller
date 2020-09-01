import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'globals.dart';

void main() async {
    await Hive.initFlutter();
    box = await Hive.openBox('dataBox');
    // colorBox = await Hive.openBox('currentColor');
    runApp(CupertinoTestApp());
}
