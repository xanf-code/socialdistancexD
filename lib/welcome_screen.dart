import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'package:flutter/material.dart';

import 'package:device_info/device_info.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  static const platform = const MethodChannel('samples.flutter.dev/battery');
  int stage = 0;
  String str = '';
  
  void registerDevice() async {
    setState(() {
      ++stage;
    });
    Response res = await dio.get('/register');
    if(res.data['id'] != null) {
      setState(() {
        stage = 2;
        str = '${res.data['id']}';
      });
    } else {
      setState(() {
        stage = 0;
        str = 'There was an error registering your device. Please try again.';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    
    List<Widget> children;
    
    if(stage == 0) {
      children = <Widget>[
        Text('Welcome to COVID-19 Contact Tracker\nWould you like to register your device?\n(You will have to rename your device to do so)'),
        Text(str, style: TextStyle(color: Colors.red)),
        OutlineButton(
          child: Text('register my device'),
          onPressed: () {
            registerDevice();
          },
        )
      ];
    }
    
    if(stage == 1) {
      children = <Widget>[
        Text('Registering your device with our servers...'),
        CircularProgressIndicator(),
      ];
    }

    if(stage == 2) {
      children = <Widget>[
        Text('Your device has been registered with our servers. To finish the process (and for the app to function), you must rename your device to: '),
        SelectableText(str, style: TextStyle(fontSize: 28)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlineButton(
              child: Text('Copy name'),
              onPressed: () async {
                Clipboard.setData(ClipboardData(text: str));
              },
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16)),
            OutlineButton(
              child: Text('Next'),
              onPressed: () async {
                String deviceName = "";
                if(Platform.isAndroid) {
                  try {
                    final String result = await platform.invokeMethod('getBatteryLevel');
                    deviceName = result;
                  } on PlatformException catch (e) {
                    debugPrint("Failed to get battery level: '${e.message}'.");
                  }
                } else {
                  deviceName = (await DeviceInfoPlugin().iosInfo).name;
                }
                if(deviceName == str) {
                  setState(() {
                    stage++;
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Device Name'),
                        content: Text('We\'ve detected your device name to be "$deviceName". This app will not work properly if your device is not named "$str".'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('continue anyway'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                stage++;
                              });
                            },
                          )
                        ],
                      );
                    }
                  );
                }
              },
            )
          ]
        ),
      ];
    }
    
    if(stage == 3) {
      children = [
        Text('Thank you for registering!'),
        OutlineButton(
          child: Text('Start using COVID-19 Contact Tracker'),
          onPressed: () {
            sharedPreferences.setString('my_id', str);
            sharedPreferences.setBool('first_run', true);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => IndexPage()));
          },
        )
      ];
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to COVID-19 Contact Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
