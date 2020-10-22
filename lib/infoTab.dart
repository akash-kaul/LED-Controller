import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class InfoTab extends StatefulWidget {
    static const title = 'Info';
    static const iosIcon = Icon(CupertinoIcons.info);
    final BluetoothCharacteristic ledChar;
    final BluetoothDevice ledDev;
    const InfoTab({Key key, this.ledChar, this.ledDev}) : super(key: key);

    @override
    _InfoTabState createState() => _InfoTabState();
}
class _InfoTabState extends State<InfoTab> {
    // @override
    // void initState() {
    //     super.initState();
    //     widget.ledChar.write(utf8.encode('Hi'));
    // }

    Future <void> _leavePage() {
        return Future.delayed(
            const Duration(milliseconds: 500), () {
                widget.ledDev.disconnect();
                Navigator.popUntil(context, ModalRoute.withName('/'));
            }
        );
    }

    Widget _buildInfo() {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget> [
                SizedBox(height: 75),
                CupertinoButton(
                    padding: EdgeInsets.only(left: 10.0),
                    color: currentTheme.getBool() ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'About',
                            style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.black)
                        ),
                    ),
                    onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => InfoPage()),
                        );
                    },
                ),
                SizedBox(height: 20),
                CupertinoButton(
                    padding: EdgeInsets.only(left: 10.0),
                    color: currentTheme.getBool() ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Flutter Homepage',
                            style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.black)
                        ),
                    ),
                    onPressed: () async {
                        const url = 'https://flutter.dev';
                        if (await canLaunch(url)) {
                            await launch(url);
                        }
                        else {
                            throw 'Could not launch $url';
                        }
                    },
                ),
                SizedBox(height: 20),
                CupertinoButton(
                    padding: EdgeInsets.only(left: 10.0),
                    color: currentTheme.getBool() ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Disconnect From This Device',
                            style: TextStyle(color: CupertinoColors.destructiveRed)
                        ),
                    ),
                    onPressed: () async {
                    final info = await showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context){
                                return CupertinoAlertDialog(
                                    title: Text('Disconnecting From Device'),
                                    content: Column(
                                        children: <Widget> [
                                            SizedBox(height: 20),
                                            Text('Are you sure you want to disconnect from this Device?'),
                                        ],
                                    ),
                                    actions: <Widget> [
                                        CupertinoButton(
                                            child: Text('DISCONNECT'),
                                            onPressed: () {
                                                // widget.ledChar.write(utf8.encode("OFF"));
                                                // _ledCharacteristicConnect.write(utf8.encode("OFF"));
                                                // widget.ledDev.disconnect();
                                                // Navigator.popUntil(context, ModalRoute.withName('/'));
                                                Navigator.pop(context, "OFF");
                                            },
                                        ),
                                        CupertinoButton(
                                            child: Text('CANCEL'),
                                            onPressed: () {
                                                Navigator.pop(context);
                                            },
                                        ),
                                    ],
                                );
                            }
                        );
                        if (info != null) {
                            widget.ledChar.write(utf8.encode('OFF'));
                            _leavePage();
                            // widget.ledDev.disconnect();
                            // Navigator.popUntil(context, ModalRoute.withName('/'));
                        };
                    },
                ),
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                padding: EdgeInsetsDirectional.only(start: 5.0),
            ),
            child: _buildInfo(),
        );
    }
}

class InfoPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                middle: Text('About'),
            ),
            child: SafeArea(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('This app was made by Akash Kaul. If you like the app, consider donating 1 million dollars to the creator :)'),
                ),
            ),
        );
    }
}
