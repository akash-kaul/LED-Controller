import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'themeNotifier.dart';
// import 'theme.dart';
import 'globals.dart';
import 'package:provider/provider.dart';

/// A simple widget that builds different things on different platforms.
// class PlatformWidget extends StatelessWidget {
//   const PlatformWidget({Key key, this.iosBuilder}): super(key: key);
//   final WidgetBuilder iosBuilder;
//
//   @override
//   Widget build(context) {
//     return iosBuilder(context);
//   }
// }
class SettingsTab extends StatefulWidget {
    static const title = 'Settings';
    static const iosIcon = Icon(CupertinoIcons.gear_big);

    @override
    _SettingsTabState createState() => _SettingsTabState();
}
class _SettingsTabState extends State<SettingsTab> {
    static bool switch1 = currentTheme.getBool();
    Widget _buildList() {
        return ListView(
            children: [
                Padding(padding: EdgeInsets.only(top: 24)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                    'Change Theme',
                                    // style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),
                                ),
                            ),
                        ),
                        // Expanded(
                        //     child: Padding(
                        //         padding: const EdgeInsets.only(right: 0),
                        //         child: CupertinoSwitch(
                        //             value: switch1,
                        //             onChanged: (bool value) {setState(() {switch1 = value; }); },
                        //         ),
                        //     ),
                        // ),
                        Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CupertinoSwitch(
                                value: switch1,
                                onChanged: (bool value) {
                                    setState(() {
                                        switch1 = value;
                                    });
                                    // onThemeChanged(value, themeNotifier);
                                    currentTheme.switchTheme();
                                    // DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
                                    // Navigator.of(context).pop(value);
                                },
                                activeColor: CupertinoColors.activeBlue,
                            ),
                        ),
                    ],
                ),
            ],
        );
    }
    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: _buildList(),
        );
    }

    // @override
    // Widget build(context) {
    //     return PlatformWidget(
    //         iosBuilder: _buildIos,
    //     );
    // }
    // void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    //   (value)
    //       ? themeNotifier.setTheme(darkTheme)
    //       : themeNotifier.setTheme(lightTheme);
    //   var prefs = await SharedPreferences.getInstance();
    //   prefs.setBool('darkMode', value);
    // }
}
