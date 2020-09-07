import 'package:flutter/cupertino.dart';
import 'theme.dart';
import 'globals.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ThemeNotifier with ChangeNotifier {

    static bool _isDark = false;
    static Set<BluetoothDevice> _devices = {};

    ThemeNotifier(){
        if(box.containsKey('currentTheme')){
            _isDark = box.get('currentTheme');
        }
        else{
            box.put('currentTheme', _isDark);
        }
        if(box.containsKey('savedDevices')){
            _devices = box.get('savedDevices');
        }
        else{
            box.put('savedDevices', _devices);
        }
    }

    CupertinoThemeData currentTheme() {
        return _isDark ? darkTheme : lightTheme;
    }

    getBool() {
        return _isDark;
    }

    getSavedDevices() {
        return _devices;
    }

    void switchTheme() {
        _isDark = !_isDark;
        box.put('currentTheme', _isDark);
        notifyListeners();
    }
    void addDevice(newDevice) {
        _devices.add(newDevice);
        box.put('savedDevices', _devices);
        notifyListeners();
    }
}
