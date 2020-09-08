import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'settingsTab.dart';
import 'infoTab.dart';
// import 'dynamicTheme.dart';
// import 'colorPicker.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'debounce.dart';
import 'globals.dart';
import 'colorWheel.dart';
// import 'themeNotifier.dart';
// import 'theme.dart';



class CupertinoTestApp extends StatefulWidget {

    @override
    _AppState createState() => _AppState();
}

class _AppState extends State<CupertinoTestApp> {
    @override
    void initState() {
        currentTheme.addListener(() {
            setState((){});
        });
    }

    @override
    Widget build (BuildContext context) {
        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
        ]);
        return CupertinoApp(
            home: HomePage(),
            // initialRoute: '/',
            // routes: {
            //     // '/': (context) => HomePage(),
            //     '/color': (context) => ColorPage(),
            // },
            debugShowCheckedModeBanner: false,
            theme: currentTheme.currentTheme(),
        );
    }
}
// class CupertinoTestApp extends StatelessWidget {
//     @override
//     Widget build (BuildContext context) {
//         return ValueListenableBuilder(
//             valueListenable: Hive.box('dataBox').listenable(),
//             builder: (context, box, widget) {
//                 var darMode = box.get('currentTheme', defaultValue: false);
//                 return CupertinoApp(
//                     home: HomePage(),
//                     debugShowCheckedModeBanner: false,
//                     theme: darkMode ? darkTheme : lightTheme,
//                 );
//             },
//         );
//
//     }
// }

class HomePage extends StatefulWidget {

    @override
    _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<HomePage> {


    // var c = new streamListener();
    // bool _switch1 = false;
    // void changeBrightness() {
    //     // if (result){
    //     DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
    //         // setState(() {_switch1 = result;});
    //     // }
    // }
    // _navigateAndDisplay(BuildContext context) async {
    //     final result = await Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //             title: SettingsTab.title,
    //             fullscreenDialog: true,
    //             builder: (context) => SettingsTab(),
    //         ),
    //     );
    //
    //     changeBrightness(result);
    // }
    // _navigateAndDisplay(BuildContext context) async {
    //     bool received = await Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //             title: SettingsTab.title,
    //             fullscreenDialog: true,
    //             builder: (_) => SettingsTab(),
    //         ),
    //     );
    //
    //     changeBrightness(received);
    // }
    _navigateAndDisplay(BuildContext context) {
        Navigator.of(context, rootNavigator: true).push<void>(
            CupertinoPageRoute(
                title: SettingsTab.title,
                fullscreenDialog: true,
                builder: (context) => SettingsTab(),
            ),
        );
    }


    Widget _buildBody(BuildContext context) {
        return SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                    Expanded(
                        flex: 10,
                        child: Center(
                            child: SizedBox(
                                child: Center(
                                    child: CupertinoButton(
                                        padding: EdgeInsets.only(left:0,top:0,right:0,bottom:20),
                                        color: CupertinoColors.activeBlue,
                                        child: Icon(
                                            CupertinoIcons.bluetooth,
                                            color: CupertinoColors.white,
                                            size: 250,
                                        ),
                                        onPressed: () {
                                            if (currentTheme.getSavedDevices().length > 0) {
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(builder: (context) => SavedDevicesPage())
                                                );
                                            }
                                            else{
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(builder: (context) => SecondPage())
                                                );
                                            }
                                        },
                                        pressedOpacity: 0.5,
                                        borderRadius: BorderRadius.circular(1000),
                                    ),
                                ),
                            ),
                        ),
                    ),
                    Expanded(
                        flex: 1,
                        child: SizedBox(),
                    ),
                ],
            ),
        );
    }
    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                padding: EdgeInsetsDirectional.only(end: 5.0),
                trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: SettingsTab.iosIcon,
                    onPressed: () {
                        // DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark ? Brightness.light: Brightness.dark);
                        _navigateAndDisplay(context);
                    },
                ),
            ),
            child: _buildBody(context),
        );
    }
    // if SettingsTab.switch1 != switch1{
    //     changeBrightness();
    //     switch1 = SettingsTab.switch1;
    // }
    // @override
    // Widget build(context) {
    //     return PlatformWidget(
    //         iosBuilder: _buildIos,
    //     );
    // }

}

// class MyButtonModal {
//     bool changeButtonChild;
//
//     MyButtonModal({this.changeButtonChild = false});
// }
class SavedDevicesPage extends StatefulWidget {
    @override
    _SavedDevicesPageState createState() => _SavedDevicesPageState();
}

class _SavedDevicesPageState extends State<SavedDevicesPage> {
    BluetoothDevice _connectedDevice;
    List<BluetoothService> _services;

    List<Widget> _buildListViewOfConnectedDevices() {
        List<Widget> containers = new List<Widget>();
        for (BluetoothDevice device in currentTheme.getSavedDevices()) {
            containers.add(
                Container(
                    height: 20,
                    child: CupertinoButton(
                        child: Text(device.name),
                        onPressed: () async {
                            try {
                                await device.connect();
                                setState(() {
                                    _connectedDevice = device;
                                });
                                _services = await device.discoverServices();
                                if (_connectedDevice != null) {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(builder: (context) => ColorPage(ledDevice: _connectedDevice, ledServices: _services)),
                                    );
                                }
                            }
                            catch (e) {
                                if (e.code != 'already_connected') {
                                    // setState(() {
                                    //    changeView[count] = true;
                                    // });
                                    await showCupertinoDialog(
                                        context: context,
                                        builder: (BuildContext context){
                                            return CupertinoAlertDialog(
                                                title: Text('Device Not Available'),
                                                content: Column(
                                                    children: <Widget> [
                                                        SizedBox(height: 20),
                                                        Text('It seems this BLE device is already connected. Please disconnect the device and try again.'),
                                                    ],
                                                ),
                                                actions: <Widget> [
                                                    CupertinoButton(
                                                        child: Text('OK'),
                                                        onPressed: () {
                                                            Navigator.pop(context);
                                                        },
                                                    ),
                                                ],
                                            );
                                        }
                                    );
                                }
                            }
                        }
                    ),
                ),
            );
        }
        return containers;
    }

    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                padding: EdgeInsetsDirectional.only(end: 5.0),
                middle: Text('Saved Devices'),
            ),
            child: SafeArea(
                child: Column(
                    children: _buildListViewOfConnectedDevices()
                ),
            ),
        );
    }
}

// class SecondPageRoute extends CupertinoPageRoute {
//     SecondPageRoute()
//         :super(builder: (BuildContext context) => new SecondPage());
// }

class SecondPage extends StatefulWidget {

    final FlutterBlue flutterBlue = FlutterBlue.instance;
    final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
    // final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

    @override
    _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

    BluetoothDevice _connectedDevice;
    List<BluetoothService> _services;

    // final _writeController = TextEditingController();
    double _height = 0;
    List<Widget> listConnect;
    // bool tryingToConnect = false;
    // Widget _buttonChild = Text('Connect', style: TextStyle(color: (currentTheme.getBool()) ? CupertinoColors.white : CupertinoColors.black));

    _addDeviceTolist(final BluetoothDevice device) {
        if (!widget.devicesList.contains(device)) {
            setState(() {
                widget.devicesList.add(device);
            });
        }
    }

    Future <void> _refreshData() {
        return Future.delayed(
            const Duration(seconds: 1), () {
                setState(() {
                    listConnect = _buildListViewOfDevices();
                });
            });
    }

    _saveDevice(newDevice) async {
        final result = await showCupertinoDialog(
            context: context,
            builder: (BuildContext context){
                return CupertinoAlertDialog(
                    title: Text('Remember Device'),
                    content: Column(
                        children: <Widget> [
                            SizedBox(height: 20),
                            Text('Would you like to remember this device?'),
                        ],
                    ),
                    actions: <Widget> [
                        CupertinoButton(
                            child: Text('YES'),
                            onPressed: () {
                                Navigator.pop(context, "YES");
                            },
                        ),
                        CupertinoButton(
                            child: Text('NO'),
                            onPressed: () {
                                Navigator.pop(context);
                            },
                        ),
                    ],
                );
            }
        );
        if (result != null) {
            currentTheme.addDevice(newDevice);
            // widget.ledDev.disconnect();
            // Navigator.popUntil(context, ModalRoute.withName('/'));
        };
    }


      @override
      void initState() {
          super.initState();
          // if (_connectedDevice != null) {
          //     Navigator.push(
          //         context,
          //         CupertinoPageRoute(builder: (context) => ColorPage(ledDevice: _connectedDevice, ledServices: _services)),
          //     );
          // }
          widget.flutterBlue.connectedDevices
            .asStream()
            .listen((List<BluetoothDevice> devices) {
            for (BluetoothDevice device in devices) {
                _addDeviceTolist(device);
            }
            // if (_connectedDevice != null){
            //     setState(() {
            //         _connectedDevice.disconnect();
            //         _connectedDevice = null;
            //     });
            // }

        });
        widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
            for (ScanResult result in results) {
                _addDeviceTolist(result.device);
            }
            // if (_connectedDevice != null){
            //     setState(() {
            //         _connectedDevice.disconnect();
            //         _connectedDevice = null;
            //     });
            // }
        });
        widget.flutterBlue.startScan();
        // setState(() {
        //     listConnect = _buildListViewOfDevices();
        // });
      }
      // create dropdown using tap on container, won't work idk
      // GestureDetector(
      //     onTap: () {
      //         _height = (_height==20) ? 0 : 20;
      //     },
      List<Widget> _buildListViewOfDevices() {
          List<Widget> containers = new List<Widget>();
          // List<bool> changeView = new List<bool>();
          // int count = 0;
          for (BluetoothDevice device in widget.devicesList) {
              // Widget _buttonChild = Text('Connect', style: TextStyle(color: (currentTheme.getBool()) ? CupertinoColors.white : CupertinoColors.black));
              // changeView.add(false);
              containers.add(
                  Container(
                      height: 65,
                      // decoration: BoxDecoration(
                      //     border: Border(bottom: BorderSide(color: CupertinoColors.black)),
                      // ),
                      child: Column(
                          children: <Widget> [
                              Padding(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                      children: <Widget>[
                                          Expanded(
                                              flex: 6,
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                      Text(device.name == '' ? '(No name device)' : device.name),
                                                  ],
                                              ),
                                          ),
                                          CupertinoButton(
                                              color: CupertinoColors.activeGreen,
                                              child: Text('Connect', style: TextStyle(color: (currentTheme.getBool()) ? CupertinoColors.white : CupertinoColors.black)),
                                              // child: changeView[count] ? CupertinoActivityIndicator() : Text('Connect', style: TextStyle(color: (currentTheme.getBool()) ? CupertinoColors.white : CupertinoColors.black)),
                                              onPressed: () async {
                                                  // setState(() {
                                                  //     changeView[count] = true;
                                                  // });
                                                  // changeView[count] = true;
                                                  widget.flutterBlue.stopScan();
                                                  try {
                                                      await device.connect();
                                                      setState(() {
                                                          _connectedDevice = device;
                                                      });
                                                      _services = await device.discoverServices();

                                                      if (_connectedDevice != null && !currentTheme.getSavedDevices().contains(_connectedDevice)){
                                                          final result = await showCupertinoDialog(
                                                              context: context,
                                                              builder: (BuildContext context){
                                                                  return CupertinoAlertDialog(
                                                                      title: Text('Remember Device'),
                                                                      content: Column(
                                                                          children: <Widget> [
                                                                              SizedBox(height: 20),
                                                                              Text('Would you like to remember this device?'),
                                                                          ],
                                                                      ),
                                                                      actions: <Widget> [
                                                                          CupertinoButton(
                                                                              child: Text('YES'),
                                                                              onPressed: () {
                                                                                  Navigator.pop(context, "YES");
                                                                              },
                                                                          ),
                                                                          CupertinoButton(
                                                                              child: Text('NO'),
                                                                              onPressed: () {
                                                                                  Navigator.pop(context);
                                                                              },
                                                                          ),
                                                                      ],
                                                                  );
                                                              }
                                                          );
                                                          if (result != null) {
                                                              currentTheme.addDevice(_connectedDevice);
                                                              // widget.ledDev.disconnect();
                                                              // Navigator.popUntil(context, ModalRoute.withName('/'));
                                                          };
                                                          Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(builder: (context) => ColorPage(ledDevice: _connectedDevice, ledServices: _services)),
                                                          );
                                                      }
                                                  }
                                                  catch (e) {
                                                      if (e.code != 'already_connected') {
                                                          // setState(() {
                                                          //    changeView[count] = true;
                                                          // });
                                                          await showCupertinoDialog(
                                                              context: context,
                                                              builder: (BuildContext context){
                                                                  return CupertinoAlertDialog(
                                                                      title: Text('Device Not Available'),
                                                                      content: Column(
                                                                          children: <Widget> [
                                                                              SizedBox(height: 20),
                                                                              Text('It seems this BLE device is already connected. Please disconnect the device and try again.'),
                                                                          ],
                                                                      ),
                                                                      actions: <Widget> [
                                                                          CupertinoButton(
                                                                              child: Text('OK'),
                                                                              onPressed: () {
                                                                                  Navigator.pop(context);
                                                                              },
                                                                          ),
                                                                      ],
                                                                  );
                                                              }
                                                          );
                                                      }
                                                  }
                                                  // finally {
                                                  //     _services = await device.discoverServices();
                                                  // }
                                              },
                                          ),
                                      ],
                                  ),
                              ),
                              // AnimatedContainer(
                              //     height: _height,
                              //     child: Text(device.id.toString()),
                              //     duration: Duration(seconds: 1),
                              //     curve: Curves.easeInOut,
                              // ),
                              Divider(color: currentTheme.getBool() ? Colors.white : Colors.black),
                          ],
                      ),
                  ),
              );
              // count = count + 1;
          }
      return containers;
      // return ListView(
      //     padding: const EdgeInsets.all(8),
      //     children:<Widget>[
      //         ...containers,
      //     ],
      // );
  }
  // Method to create buttons Read/Write/notify
  // List<Padding> _buildReadWriteNotifyButton(BluetoothCharacteristic characteristic) {
  //     List<Padding> buttons = new List<Padding>();
  //
  //     if (characteristic.properties.read) {
  //         buttons.add(
  //             Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 4),
  //                 child: RaisedButton(
  //                     color: CupertinoColors.activeBlue,
  //                     child: Text('READ', style: TextStyle(color: CupertinoColors.white)),
  //                     onPressed: () async {
  //                         var sub = characteristic.value.listen((value) {
  //                             setState(() {
  //                                 widget.readValues[characteristic.uuid] = value;
  //                             });
  //                         });
  //                         await characteristic.read();
  //                         sub.cancel();
  //                     },
  //                 ),
  //             ),
  //         );
  //     }
  //
  //     if (characteristic.properties.write) {
  //         buttons.add(
  //             Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 4),
  //                 child: RaisedButton(
  //                     color: CupertinoColors.activeBlue,
  //                     child: Text('WRITE', style: TextStyle(color: CupertinoColors.white)),
  //                     onPressed: () async {
  //                         await showCupertinoDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                                 return CupertinoAlertDialog(
  //                                     title: Text("Write Data"),
  //                                     content: Row(
  //                                         children: <Widget> [
  //                                             Expanded(
  //                                                 child: CupertinoTextField(
  //                                                     controller: _writeController,
  //                                                 ),
  //                                             ),
  //                                         ],
  //                                     ),
  //                                     actions: <Widget> [
  //                                         CupertinoButton(
  //                                             child: Text("Send"),
  //                                             onPressed: () {
  //                                                 characteristic.write(
  //                                                     utf8.encode(_writeController.value.text)
  //                                                 );
  //                                                 Navigator.pop(context);
  //                                             },
  //                                         ),
  //                                         CupertinoButton(
  //                                             child: Text("Cancel"),
  //                                             onPressed: () {
  //                                                 Navigator.pop(context);
  //                                             },
  //                                         ),
  //                                     ],
  //                                 );
  //                             });
  //                     },
  //                 ),
  //             ),
  //         );
  //     }
  //
  //     if (characteristic.properties.notify) {
  //         buttons.add(
  //             Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 4),
  //                 child: RaisedButton(
  //                     child: Text('NOTIFY', style: TextStyle(color: CupertinoColors.white)),
  //                     onPressed: () async {
  //                         characteristic.value.listen((value) {
  //                             widget.readValues[characteristic.uuid] = value;
  //                         });
  //                         await characteristic.setNotifyValue(true);
  //                     },
  //                 ),
  //             ),
  //         );
  //     }
  //
  //     return buttons;
  // }

  // method to create dropdown list with read/write buttons
  // ListView _buildConnectDeviceView() {
  //     List<Container> containers = new List<Container>();
  //
  //     for (BluetoothService service in _services) {
  //         List<Widget> characteristicsWidget = new List<Widget>();
  //
  //         for (BluetoothCharacteristic characteristic in service.characteristics) {
  //             characteristicsWidget.add(
  //                 Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: Column(
  //                         children: <Widget>[
  //                             Row(
  //                                 children: <Widget> [
  //                                     Text('Characteristic UUID: ' + characteristic.uuid.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
  //                                 ],
  //                             ),
  //                             Row(
  //                                 children: <Widget> [
  //                                     ..._buildReadWriteNotifyButton(characteristic),
  //                                 ],
  //                             ),
  //                             Row(
  //                                 children: <Widget> [
  //                                     Text('Value: ' + widget.readValues[characteristic.uuid].toString()),
  //                                 ],
  //                             ),
  //                             Divider(),
  //                         ],
  //                     ),
  //                 ),
  //             );
  //         }
  //
  //         containers.add(
  //             Container(
  //                 child: ExpansionTile(
  //                     title: Text('Service UUID: ' + service.uuid.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
  //                     children: characteristicsWidget,
  //                     trailing: null,
  //                 ),
  //             ),
  //         );
  //     }
  //
  //     return ListView(
  //         padding: const EdgeInsets.all(8),
  //         children: <Widget> [
  //             ...containers,
  //         ],
  //     );
  // }

    @override
    Widget build(BuildContext context) {
        // if (_connectedDevice != null) {
        //     return Scaffold(
        //         body: _buildConnectDeviceView(),
        //     );
        // }
        return CupertinoPageScaffold(
            child: SizedBox(
                height: 1000,
                child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      CupertinoSliverNavigationBar(
                        // automaticallyImplyLeading: false,
                        largeTitle: Text(
                          'Select Device',
                          style: TextStyle(),
                        ),
                      ),
                      CupertinoSliverRefreshControl(
                        onRefresh: _refreshData,
                      ),
                      SliverSafeArea(
                        top: false,
                        sliver: SliverPadding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            sliver: SliverList(
                                delegate: SliverChildListDelegate(
                                    (listConnect != null) ? listConnect : _buildListViewOfDevices(),
                                ),
                            ),
                        ),

                      ),
                    ],
                ),
            ),
        );
    }
}

class ColorPage extends StatefulWidget {
    final BluetoothDevice ledDevice;
    final List<BluetoothService> ledServices;
    const ColorPage({Key key, this.ledDevice, this.ledServices}) : super(key: key);

    @override
    _ColorPageState createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
    final _writeController = TextEditingController();
    // final _debouncer = Debouncer(milliseconds: 250);
    // int count = 0;
    double _height = 0;
    double _height2 = 0;
    double _dropdownHeight1 = 0;
    double _dropdownHeight2 = 0;
    double _dropdownHeight3 = 0;
    bool pressAttention = false;
    double sliderValue = 64;
    int currentTabIndex = 0;
    final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();
    BluetoothService _ledServiceConnect;
    BluetoothCharacteristic _ledCharacteristicConnect;
    Color currentColor;
    String sendValue;
    // int currentAlpha = 0;
    // Map<String, int> myData = new Map();
    // calculateNewValue(int oldValue) {
    //     int oldRange = oldValue - 4278190080;
    //     int newRange = 255;
    //     double newValue = (((oldValue - 4278190080) * newRange) / 16777225);
    //     return newValue.round();
    // }


    // HSVColor color = HSVColor.fromColor(Colors.white);
    // void onChanged(HSVColor color){
    //     this.color = color;
    // }

    @override
    void initState() {
        super.initState();
        setState(() {
            _ledServiceConnect = widget.ledServices.first;
            _ledCharacteristicConnect = _ledServiceConnect.characteristics.first;
        });
    }


    List<Padding> _buildReadWriteNotifyButton(BluetoothCharacteristic characteristic) {
        List<Padding> buttons = new List<Padding>();

        if (characteristic.properties.read) {
            buttons.add(
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RaisedButton(
                        color: CupertinoColors.activeBlue,
                        child: Text('READ', style: TextStyle(color: CupertinoColors.white)),
                        onPressed: () async {
                            var sub = characteristic.value.listen((value) {
                                setState(() {
                                    readValues[characteristic.uuid] = value;
                                });
                            });
                            await characteristic.read();
                            sub.cancel();
                        },
                    ),
                ),
            );
        }

        if (characteristic.properties.write) {
            buttons.add(
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RaisedButton(
                        color: CupertinoColors.activeBlue,
                        child: Text('WRITE', style: TextStyle(color: CupertinoColors.white)),
                        onPressed: () async {
                            await showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                        title: Text("Write Data"),
                                        content: Row(
                                            children: <Widget> [
                                                Expanded(
                                                    child: CupertinoTextField(
                                                        controller: _writeController,
                                                    ),
                                                ),
                                            ],
                                        ),
                                        actions: <Widget> [
                                            CupertinoButton(
                                                child: Text("Send"),
                                                onPressed: () {
                                                    characteristic.write(
                                                        utf8.encode(_writeController.value.text)
                                                    );
                                                    Navigator.pop(context);
                                                },
                                            ),
                                            CupertinoButton(
                                                child: Text("Cancel"),
                                                onPressed: () {
                                                    Navigator.pop(context);
                                                },
                                            ),
                                        ],
                                    );
                                });
                        },
                    ),
                ),
            );
        }

        if (characteristic.properties.notify) {
            buttons.add(
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RaisedButton(
                        child: Text('NOTIFY', style: TextStyle(color: CupertinoColors.white)),
                        onPressed: () async {
                            characteristic.value.listen((value) {
                                readValues[characteristic.uuid] = value;
                            });
                            await characteristic.setNotifyValue(true);
                        },
                    ),
                ),
            );
        }

        return buttons;
    }

    List<Widget> _buildConnectDeviceView() {
        List<Container> containers = new List<Container>();

        for (BluetoothService service in widget.ledServices) {
            List<Widget> characteristicsWidget = new List<Widget>();

            for (BluetoothCharacteristic characteristic in service.characteristics) {
                characteristicsWidget.add(
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                            children: <Widget>[
                                Row(
                                    children: <Widget> [
                                        Text('Characteristic UUID: ' + characteristic.uuid.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                ),
                                Row(
                                    children: <Widget> [
                                        ..._buildReadWriteNotifyButton(characteristic),
                                    ],
                                ),
                                Row(
                                    children: <Widget> [
                                        Text('Value: ' + readValues[characteristic.uuid].toString()),
                                    ],
                                ),
                                Divider(),
                            ],
                        ),
                    ),
                );
            }

            containers.add(
                Container(
                    // child: ExpansionTile(
                    //     title: Text('Service UUID: ' + service.uuid.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                    //     children: characteristicsWidget,
                    //     trailing: null,
                    // ),
                    child: Column(
                        children: characteristicsWidget,
                    ),
                ),
            );
        }

        // return ListView(
        //     padding: const EdgeInsets.all(8),
        //     children: <Widget> [
        //         ...containers,
        //     ],
        // );
        return containers;
    }

    List<Widget> _buildColors() {
        List<Widget> containers = new List<Widget>();
        // containers.add(
        //     Container(
        //         width: double.infinity,
        //         // padding: const EdgeInsets.all(8),
        //         // color: Colors.pink,
        //         child: RaisedButton(
        //             color: Colors.pink,
        //             elevation: 5,
        //             onPressed: () {},
        //         ),
        //     ),
        // );
        containers.add(
            RaisedButton(
                color: Colors.pink,
                splashColor: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                focusElevation: 0,
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.pink.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.pink.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.red,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.red.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.red.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.deepOrange,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.deepOrange.value);
                        sendValue = Color(Colors.deepOrange.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.orange,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.orange.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.orange.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.amber,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.amber.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.amber.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.yellow,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.yellow.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.yellow.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.lime,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.lime.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.lime.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.lightGreen,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.lightGreen.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.lightGreen.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.green,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.green.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.green.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.teal,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.teal.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.teal.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.cyan,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.cyan.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.cyan.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.lightBlue,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.lightBlue.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.lightBlue.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.blue,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.blue.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.blue.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.indigo,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.indigo.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.indigo.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.purple,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.purple.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.purple.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.deepPurple,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.deepPurple.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.deepPurple.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            )
        );

        containers.add(
            RaisedButton(
                color: Colors.blueGrey,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.blueGrey.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.blueGrey.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            ),
        );

        containers.add(
            RaisedButton(
                color: Colors.brown,
                splashColor: Colors.transparent,
                elevation: 10,
                focusElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.brown.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.brown.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            ),
        );

        containers.add(
            RaisedButton(
                elevation: 10,
                focusElevation: 0,
                color: Colors.transparent,
                splashColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                padding: EdgeInsets.all(0.0),
                // shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                child: Container(
                    width: double.infinity,
                    // height: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        gradient: LinearGradient(
                            colors: <Color>[
                                const Color(0xFFFF0064),
                                const Color(0xFFFF7600),
                                const Color(0xFFFFD500),
                                const Color(0xFF8CFE00),
                                const Color(0xFF00E86C),
                                const Color(0xFF00F4F2),
                                const Color(0xFF00CCFF),
                                const Color(0xFF70A2FF),
                                const Color(0xFFA96CFF),
                            ],
                        ),
                    ),
                ),
                onPressed: () {
                    setState(() {
                        // lastValueWasColor = true;
                        sendValue = 'Rainbow';
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            ),
        );

        containers.add(
            RaisedButton(
                color: Colors.white,
                splashColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                elevation: 10,
                focusElevation: 0,
                onPressed: () {
                    setState(() {
                        currentColor = Color(Colors.white.value);
                        // lastValueWasColor = true;
                        sendValue = Color(Colors.white.value).toString();
                    });
                    _ledCharacteristicConnect.write(utf8.encode(sendValue));
                },
            ),
        );
        return containers;
    }
    _navigateAndDisplay(BuildContext context) async{
        Navigator.of(context).push<void>(
            CupertinoPageRoute(
                title: InfoTab.title,
                fullscreenDialog: true,
                builder: (context) => InfoTab(ledChar: _ledCharacteristicConnect, ledDev: widget.ledDevice),
            ),
        );
        // _ledCharacteristicConnect.write(utf8.encode("OFF"));
        // widget.ledDevice.disconnect();
        // Navigator.popUntil(context, ModalRoute.withName('/'));
        // Navigator.pop(context);
    }

    Widget _buildInfo(BuildContext context) {

        return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
                items: <BottomNavigationBarItem> [
                    BottomNavigationBarItem(icon: Icon(Icons.format_color_fill), title: Text('COLORS')),
                    BottomNavigationBarItem(icon: Icon(Icons.menu), title: Text('ANIMATIONS')),
                ],
                currentIndex: currentTabIndex,
                onTap: (int index) {
                    setState(() {
                        currentTabIndex = index;
                    });
                },
            ),
            tabBuilder: (BuildContext context, int index) {
                return CupertinoTabView(
                    builder: (BuildContext context) {
                        if (index == 0) {
                            return CupertinoPageScaffold(
                                // navigationBar: CupertinoNavigationBar(
                                //     middle: Text(widget.ledDevice.name),
                                //     // leading: CupertinoNavigationBarBackButton(
                                //     //     color: Colors.white,
                                //     // ),
                                //     // automaticallyImplyLeading: true,
                                //     // middle: Text('Page 1 of tab $index'),
                                // ),
                                child: SafeArea(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget> [
                                            SizedBox(
                                                width: double.infinity,
                                                child: CupertinoButton(
                                                    color: pressAttention ? CupertinoColors.activeOrange : CupertinoColors.activeBlue,
                                                    child: Text(pressAttention ? "Turn LEDs OFF" : "Turn LEDs ON", style: TextStyle(color: CupertinoColors.white)),
                                                    onPressed: () {
                                                        setState(() {
                                                            if (_height == 450){
                                                                _height = 0;
                                                                _height2 = 0;
                                                            }
                                                            else{
                                                                _height = 450;
                                                                _height2 = 50;
                                                            }
                                                            pressAttention = !pressAttention;
                                                        });
                                                        if (pressAttention){
                                                            // if (box.containsKey('currentColor')){
                                                            //     setState(() => currentColor = box.get('currentColor'));
                                                            //
                                                            // }
                                                            // else {
                                                            //     setState(() => currentColor = Colors.white);
                                                            //     box.put('currentColor', Colors.white);
                                                            // }
                                                            if (sendValue == null){
                                                                setState(() {
                                                                    sendValue = Color(Colors.white.value).toString();
                                                                });
                                                            }
                                                            _ledCharacteristicConnect.write(utf8.encode(sendValue));

                                                        }
                                                        else {
                                                            _ledCharacteristicConnect.write(utf8.encode("OFF"));
                                                        }
                                                    }
                                                ),
                                            ),
                                            AnimatedContainer(
                                                height: _height,
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                child: CustomScrollView(
                                                    slivers: <Widget> [
                                                        SliverPadding(
                                                            padding: const EdgeInsets.all(20),
                                                            sliver: SliverGrid.count(
                                                                crossAxisSpacing: 10,
                                                                mainAxisSpacing: 10,
                                                                crossAxisCount: 4,
                                                                children: _buildColors(),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                            ),
                                            AnimatedContainer(
                                                height: _height2,
                                                alignment: Alignment.bottomRight,
                                                padding: EdgeInsets.only(top: 6.0),
                                                width: double.infinity,
                                                child: (_height2 > 0)
                                                    ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget> [
                                                        CupertinoSlider(
                                                            activeColor: CupertinoColors.activeBlue,
                                                            value: sliderValue,
                                                            max: 255,
                                                            min: 0,
                                                            divisions: 20,
                                                            onChanged: (double val) {
                                                                setState(() {
                                                                    sliderValue = val;
                                                                });
                                                                _ledCharacteristicConnect.write(
                                                                            utf8.encode('Brightness:' + val.round().toString()));
                                                            }
                                                        ),
                                                        FloatingActionButton(
                                                            backgroundColor: Colors.red,

                                                            // , style: TextStyle(color: Colors.black)
                                                            child: pressAttention ? Icon(Icons.add) : null,
                                                            onPressed: () async {
                                                                final info = await showCupertinoDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                        Color tempColor = currentColor;
                                                                        return StatefulBuilder(
                                                                            builder: (context, setState){
                                                                                return CupertinoAlertDialog(
                                                                                    title: Text('Choose Color'),
                                                                                    content: Align(
                                                                                        alignment: Alignment.center,
                                                                                        child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            children: <Widget> [
                                                                                                SizedBox(height: 20),
                                                                                                CircleColorPicker(
                                                                                                    thumbRadius: 10,
                                                                                                    thumbColor: Colors.white,
                                                                                                    initialColor: currentColor,
                                                                                                    colorListener: (int value) {
                                                                                                        setState(() {
                                                                                                            tempColor = Color(value);
                                                                                                            // myData['color'] = value;
                                                                                                        });
                                                                                                    },
                                                                                                ),
                                                                                                // SizedBox(height: 20),
                                                                                                // BarColorPicker(
                                                                                                //     cornerRadius: 10,
                                                                                                //     pickMode: PickMode.Grey,
                                                                                                //     colorListener: (int value) {
                                                                                                //         setState(() {
                                                                                                //             currentAlpha = calculateNewValue(Color(value).value);
                                                                                                //              myData['alpha'] = currentAlpha;
                                                                                                //         });
                                                                                                //     },
                                                                                                // ),
                                                                                                SizedBox(
                                                                                                    height: 20,
                                                                                                    child: Text('Preview'),
                                                                                                ),
                                                                                                Container(
                                                                                                  width: double.infinity,
                                                                                                  height: 50,
                                                                                                  alignment: Alignment.center,
                                                                                                  decoration: BoxDecoration(
                                                                                                      color: tempColor,
                                                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                                  ),
                                                                                                ),
                                                                                            ],
                                                                                        ),
                                                                                    ),
                                                                                    actions: <Widget> [
                                                                                        CupertinoButton(
                                                                                            child: Text('Confirm', style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.activeBlue)),
                                                                                            onPressed: () {
                                                                                                Navigator.pop(context, tempColor);
                                                                                            },
                                                                                        ),
                                                                                        CupertinoButton(
                                                                                            child: Text('Cancel', style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.activeBlue)),
                                                                                            onPressed: () {
                                                                                                Navigator.pop(context);
                                                                                            },
                                                                                        ),
                                                                                    ],
                                                                                );
                                                                            },
                                                                        );
                                                                    },
                                                                );
                                                                if (info != null) {
                                                                    setState((){
                                                                        sendValue = info.toString();
                                                                        currentColor = info;
                                                                    });
                                                                    // box.put('currentColor', currentColor);
                                                                    _ledCharacteristicConnect.write(
                                                                                utf8.encode(sendValue));
                                                                };
                                                            },
                                                        ),
                                                    ],
                                                )
                                                : FloatingActionButton(
                                                    backgroundColor: Colors.red,

                                                    // , style: TextStyle(color: Colors.black)
                                                    child: pressAttention ? Icon(Icons.add) : null,
                                                ),
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                            ),
                                        ],
                                    ),
                                ),
                            );
                        };
                        if (index == 1) {
                            return CupertinoPageScaffold(
                                // navigationBar: CupertinoNavigationBar(
                                //     middle: Text(widget.ledDevice.name),
                                //     // middle: Text('Page 1 of tab $index'),
                                // ),
                                child: SafeArea(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget> [
                                            SizedBox(
                                                width: double.infinity,
                                                child: CupertinoButton(
                                                    color: pressAttention ? CupertinoColors.activeOrange : CupertinoColors.activeBlue,
                                                    child: Text(pressAttention ? "Turn LEDs OFF" : "Turn LEDs ON", style: TextStyle(color: CupertinoColors.white)),
                                                    onPressed: () {
                                                        setState(() {
                                                            if (_height == 450){
                                                                _height = 0;
                                                                _height2 = 0;
                                                            }
                                                            else{
                                                                _height = 450;
                                                                _height2 = 50;
                                                            }
                                                            pressAttention = !pressAttention;
                                                        });
                                                        if (pressAttention){
                                                            // if (box.containsKey('currentColor')){
                                                            //     setState(() => currentColor = box.get('currentColor'));
                                                            //
                                                            // }
                                                            // else {
                                                            //     setState(() => currentColor = Colors.white);
                                                            //     box.put('currentColor', Colors.white);
                                                            // }
                                                            if (sendValue == null){
                                                                setState(() {
                                                                    sendValue = Color(Colors.white.value).toString();
                                                                });
                                                            }
                                                            _ledCharacteristicConnect.write(utf8.encode(sendValue));

                                                        }
                                                        else {
                                                            _ledCharacteristicConnect.write(utf8.encode("OFF"));
                                                        }
                                                    }
                                                ),
                                            ),
                                            AnimatedContainer(
                                                height: _height,
                                                alignment: Alignment.topCenter,
                                                width: double.infinity,
                                                // child: CupertinoButton(
                                                //     child: Text(
                                                //         'TEST',
                                                //         style: TextStyle(color: Colors.white),
                                                //     ),
                                                //     onPressed: () {
                                                //         _ledCharacteristicConnect.write(utf8.encode('Fire'));
                                                //     }
                                                // ),
                                                child: SingleChildScrollView(
                                                    physics: NeverScrollableScrollPhysics(),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: <Widget> [
                                                            SizedBox(height: 20),
                                                            SizedBox(
                                                                width: double.infinity,
                                                                child: CupertinoButton(
                                                                    color: currentTheme.getBool() ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                    child: Text('Premade Animations', style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.black)),
                                                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                                                    onPressed: () {
                                                                        setState(() {
                                                                            if (_dropdownHeight1 == 150){
                                                                                _dropdownHeight1 = 0;
                                                                            }
                                                                            else{
                                                                                _dropdownHeight1 = 150;
                                                                            }
                                                                        });
                                                                    }
                                                                ),
                                                            ),
                                                            AnimatedContainer(
                                                                height: _dropdownHeight1,
                                                                alignment: Alignment.topCenter,
                                                                width: double.infinity,
                                                                child: GridView.count(
                                                                    childAspectRatio: 3.0,
                                                                    primary: false,
                                                                    physics: ClampingScrollPhysics(),
                                                                    padding: const EdgeInsets.all(20),
                                                                    crossAxisSpacing: 10,
                                                                    mainAxisSpacing: 5,
                                                                    crossAxisCount: 2,
                                                                    children: <Widget> [
                                                                        RaisedButton(
                                                                            splashColor: Colors.transparent,
                                                                            elevation: 10,
                                                                            focusElevation: 0,
                                                                            padding: EdgeInsets.all(0.0),
                                                                            child: Container(
                                                                                width: double.infinity,
                                                                                // height: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                    // borderRadius: BorderRadius.all(Radius.circular(50)),
                                                                                    gradient: LinearGradient(
                                                                                        colors: <Color>[
                                                                                            const Color(0xFFFF0064),
                                                                                            const Color(0xFFFF7600),
                                                                                            const Color(0xFFFFD500),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: Text('Fire', style: TextStyle(color: Colors.white)),
                                                                                ),
                                                                            ),
                                                                            // color: currentTheme.getBool() ? CupertinoColors.lightBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                            color: Colors.grey,
                                                                            onPressed: () {
                                                                                setState(() {
                                                                                    sendValue = "Fire";
                                                                                    // lastValueWasColor = false;
                                                                                });
                                                                                _ledCharacteristicConnect.write(utf8.encode(sendValue));
                                                                            },
                                                                        ),
                                                                        RaisedButton(
                                                                            splashColor: Colors.transparent,
                                                                            elevation: 10,
                                                                            focusElevation: 0,
                                                                            child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                children: <Widget> [
                                                                                    Text('Bouncing Balls', style: TextStyle(color: Colors.white)),
                                                                                    // Padding(
                                                                                    //     padding: EdgeInsets.
                                                                                    // )
                                                                                    Icon(Icons.bubble_chart, color: Colors.white, size: 30),
                                                                                ],
                                                                            ),
                                                                            // color: currentTheme.getBool() ? CupertinoColors.lightBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                            color: Colors.grey,
                                                                            onPressed: () {
                                                                                setState(() {
                                                                                    sendValue = "BouncingBalls";
                                                                                    // lastValueWasColor = false;
                                                                                });
                                                                                _ledCharacteristicConnect.write(utf8.encode(sendValue));
                                                                            },
                                                                        ),
                                                                        RaisedButton(
                                                                            splashColor: Colors.transparent,
                                                                            elevation: 10,
                                                                            focusElevation: 0,
                                                                            padding: EdgeInsets.all(0.0),
                                                                            child: Container(
                                                                                width: double.infinity,
                                                                                // height: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                    // borderRadius: BorderRadius.all(Radius.circular(50)),
                                                                                    gradient: LinearGradient(
                                                                                        colors: <Color>[
                                                                                            const Color(0xFF00E86C),
                                                                                            // const Color(0xFF00F4F2),
                                                                                            const Color(0xFF00CCFF),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: Text('Ocean', style: TextStyle(color: Colors.white)),
                                                                                ),
                                                                            ),
                                                                            // color: currentTheme.getBool() ? CupertinoColors.lightBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                            // color: Colors.grey,
                                                                            onPressed: () {
                                                                                setState(() {
                                                                                    sendValue = "Pacifica";
                                                                                    // lastValueWasColor = false;
                                                                                });
                                                                                _ledCharacteristicConnect.write(utf8.encode(sendValue));
                                                                            },
                                                                        ),
                                                                        RaisedButton(
                                                                            splashColor: Colors.transparent,
                                                                            elevation: 10,
                                                                            focusElevation: 0,
                                                                            child: Text('Test', style: TextStyle(color: Colors.white)),
                                                                            // color: currentTheme.getBool() ? CupertinoColors.lightBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                            color: Colors.grey,
                                                                            onPressed: () {
                                                                                setState(() {
                                                                                    // lastValueWasColor = false;
                                                                                });
                                                                                _ledCharacteristicConnect.write(utf8.encode(sendValue));
                                                                            },
                                                                        ),
                                                                        RaisedButton(
                                                                            splashColor: Colors.transparent,
                                                                            elevation: 10,
                                                                            focusElevation: 0,
                                                                            padding: EdgeInsets.all(0.0),
                                                                            child: Container(
                                                                                width: double.infinity,
                                                                                // height: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                    // borderRadius: BorderRadius.all(Radius.circular(50)),
                                                                                    gradient: LinearGradient(
                                                                                        colors: <Color>[
                                                                                            const Color(0xFFFF0064),
                                                                                            const Color(0xFFFF7600),
                                                                                            const Color(0xFFFFD500),
                                                                                            const Color(0xFF8CFE00),
                                                                                            const Color(0xFF00E86C),
                                                                                            const Color(0xFF00F4F2),
                                                                                            const Color(0xFF00CCFF),
                                                                                            const Color(0xFF70A2FF),
                                                                                            const Color(0xFFA96CFF),
                                                                                        ],
                                                                                    ),
                                                                                ),
                                                                                child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: Text('Rainbow', style: TextStyle(color: Colors.white)),
                                                                                ),
                                                                            ),
                                                                            // color: currentTheme.getBool() ? CupertinoColors.lightBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                            // color: Colors.grey,
                                                                            onPressed: () {
                                                                                setState(() {
                                                                                    sendValue = "Rainbow";
                                                                                    // lastValueWasColor = false;
                                                                                });
                                                                                _ledCharacteristicConnect.write(utf8.encode(sendValue));
                                                                            },
                                                                        ),
                                                                        RaisedButton(
                                                                            splashColor: Colors.transparent,
                                                                            elevation: 10,
                                                                            focusElevation: 0,
                                                                            child: Text('Test', style: TextStyle(color: Colors.white)),
                                                                            // color: currentTheme.getBool() ? CupertinoColors.lightBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                            color: Colors.grey,
                                                                            onPressed: () {
                                                                                setState(() {
                                                                                    // lastValueWasColor = false;
                                                                                });
                                                                                _ledCharacteristicConnect.write(utf8.encode(sendValue));
                                                                            },
                                                                        ),
                                                                    ],
                                                                ),
                                                                duration: Duration(milliseconds: 500),
                                                                curve: Curves.easeInOut,
                                                            ),
                                                            SizedBox(height: 20),
                                                            SizedBox(
                                                                width: double.infinity,
                                                                child: CupertinoButton(
                                                                    color: currentTheme.getBool() ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                                    child: Text('Customizable Animations', style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.black)),
                                                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                                                    onPressed: () {
                                                                        setState(() {
                                                                            if (_dropdownHeight2 == 150){
                                                                                _dropdownHeight2 = 0;
                                                                            }
                                                                            else{
                                                                                _dropdownHeight2 = 150;
                                                                            }
                                                                        });
                                                                    }
                                                                ),
                                                            ),
                                                            AnimatedContainer(
                                                                height: _dropdownHeight2,
                                                                alignment: Alignment.topCenter,
                                                                width: double.infinity,
                                                                child: CupertinoButton(
                                                                    child: Text('Dropdown 2'),
                                                                    onPressed: () {
                                                                        _ledCharacteristicConnect.write(utf8.encode("Fire"));
                                                                    },
                                                                ),
                                                                duration: Duration(milliseconds: 500),
                                                                curve: Curves.easeInOut,
                                                            ),
                                                            // SizedBox(height: 20),
                                                            // SizedBox(
                                                            //     width: double.infinity,
                                                            //     child: CupertinoButton(
                                                            //         color: currentTheme.getBool() ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                                                            //         child: Text('Random Animations', style: TextStyle(color: currentTheme.getBool() ? CupertinoColors.white : CupertinoColors.black)),
                                                            //         borderRadius: BorderRadius.all(Radius.circular(0)),
                                                            //         onPressed: () {
                                                            //             setState(() {
                                                            //                 if (_dropdownHeight3 == 100){
                                                            //                     _dropdownHeight3 = 0;
                                                            //                 }
                                                            //                 else{
                                                            //                     _dropdownHeight3 = 100;
                                                            //                 }
                                                            //             });
                                                            //         }
                                                            //     ),
                                                            // ),
                                                            // AnimatedContainer(
                                                            //     height: _dropdownHeight3,
                                                            //     alignment: Alignment.topCenter,
                                                            //     width: double.infinity,
                                                            //     child: Text('Dropdown 3'),
                                                            //     duration: Duration(milliseconds: 500),
                                                            //     curve: Curves.easeInOut,
                                                            // ),
                                                        ],
                                                    ),
                                                ),
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                            ),
                                        ],
                                    ),
                                ),
                            );
                        };
                    },
                );
            },
        );
    }
    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                padding: EdgeInsetsDirectional.only(end: 5.0),
                middle: Text(widget.ledDevice.name),
                trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: InfoTab.iosIcon,
                    onPressed: () {
                        // DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark ? Brightness.light: Brightness.dark);
                        _navigateAndDisplay(context);
                    },
                ),
            ),
            child: _buildInfo(context),
        );
    }
}


// class HomePage extends StatefulWidget {
//     @override
//     _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//     final String SERVICE_UUID = "";
//     final String CHARACTERISTIC_UUID = "";
//     final String TARGET_DEVICE_NAME = "";
//
//     FlutterBlue flutterBlue = FlutterBlue.instance;
//     StreamSubscription<ScanResult> scanSubscription;
//
//     BluetoothDevice targetDevice;
//     BluetoothCharacteristic targetCharacteristic;
//
//     String connectionText = "";
//
//     @override
//     void initState() {
//         super.initState();
//         startScan();
//     }
//
//     startScan() {
//         setState(() {
//             connectionText = "Start Scanning";
//         });
//
//         scanSubscription = flutterBlue.scan().listen((scanResult) {
//             if (scanResult.device.name == TARGET_DEVICE_NAME) {
//                 print('DEVICE found');
//                 stopScan();
//                 setState(() {
//                     connectionText = "Found Target Device";
//                 });
//
//                 targetDevice = scanResult.device;
//                 connectToDevice();
//             }
//         }, onDone: () => stopScan());
//     }
//
//     stopScan() {
//         scanSubscription?.cancel();
//         scanSubscription = null;
//     }
//
//     connectToDevice() async {
//         if (targetDevice == null) return;
//
//         setState(() {
//             connectionText = "Device Connecting";
//         });
//
//         await targetDevice.connect();
//         print('Device Connected');
//         setState(() {
//             connectionText = "Device Connected";
//         });
//
//         discoverServices();
//     }
//
//     disconnectFromDevice() {
//         if(targetDeivce == null) return;
//
//         targetDevice.disconnect();
//
//         setState(() {
//             connectionText = "Device Disconnected";
//         });
//     }
//
//     discoverServices() async {
//         if(targetDevice == null) return;
//
//         List<BluetoothService> services = await targetDevice.discoverServices();
//         services.forEach((service) {
//           // do something with service
//           if (service.uuid.toString() == SERVICE_UUID) {
//             service.characteristics.forEach((characteristic) {
//               if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
//                 targetCharacteristic = characteristic;
//                 writeData("Hi there, ESP32!!");
//                 setState(() {
//                   connectionText = "All Ready with ${targetDevice.name}";
//                 });
//               }
//             });
//           }
//       });
//     }
//
//     writeData(String data) {
//         if(targetCharacteristic == null) return;
//
//         List<int> bytes = utf8.encode(data);
//         targetCharacteristic.write(bytes);
//     }
//
//     @override
//     Widget build(BuildContext context) {
//
//     }
//
// }
//     @override
//     Widget build(BuildContext context) {
//         return const CupertinoPageScaffold(
//             navigationBar: CupertinoNavigationBar(
//                 middle: Text('Scan for Devices'),
//             ),
//             child: SizedBox(
//                 child: Center(
//                     child: CupertinoActivityIndicator(),
//                 ),
//             ),
//         );
//     }
