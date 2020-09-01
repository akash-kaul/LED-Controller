import 'package:flutter/cupertino.dart';
import 'theme.dart';
import 'globals.dart';

class ThemeNotifier with ChangeNotifier {

    static bool _isDark = false;

    ThemeNotifier(){
        if(box.containsKey('currentTheme')){
            _isDark = box.get('currentTheme');
        }
        else{
            box.put('currentTheme', _isDark);
        }
    }

    CupertinoThemeData currentTheme() {
        return _isDark ? darkTheme : lightTheme;
    }

    getBool() {
        return _isDark;
    }

    void switchTheme() {
        _isDark = !_isDark;
        box.put('currentTheme', _isDark);
        notifyListeners();
    }
}
