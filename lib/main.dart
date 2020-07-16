import 'alert_page.dart';
import 'sessions_page.dart';
import 'settings_page.dart';
import 'startpage.dart';
import 'session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:wakelock/wakelock.dart';

void main() => runApp(MyApp());

SharedPreferences sharedPreferences;
Dio dio;

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCaronaGo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: StartPage(),
    );
  }
}

class IndexPage extends StatefulWidget {

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  int index = 0;
  List<Widget> pages = [BroadcastPage(), SessionsPage(), AlertPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.speaker_phone),
            title: Text('Go Out'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Sessions'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            title: Text('Alerts')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ]
      ),
    );
  }
}

class BroadcastPage extends StatefulWidget {
  BroadcastPage({Key key}) : super(key: key);
  @override
  _BroadcastPageState createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {

  bool _scanning = false;
  bool _shouldStop = true;
  bool _sendingData = false;
  String _error = '';
  Session currentSession;
  FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();

  @override
  void initState() {

    sharedPreferences.setString('my_id', '2');

    super.initState();

    currentSession = Session();

    _bluetooth.devices.listen((device) {
      if(device.name.startsWith("COVID19-"))
      setState(() {
        currentSession.add('${device.name}'.split('-')[1]);
      });
    });
    _bluetooth.scanStopped.listen((device) {
      debugPrint('2: $_shouldStop && $_scanning');
      if(!_shouldStop) {
        tryBluetoothAgain();
      } else {
        setState(() {
          _scanning = false;
        });
      }
    });
  }

  void tryBluetoothAgain() {
    debugPrint('lol');
    _bluetooth.startScan();
  }

  void sendSession() async {
    setState(() {
      _sendingData = true;
    });
    try {
      await currentSession.send();
      debugPrint('success');
      setState(() {
        _error = '';
        _sendingData = false;
        List<String> strTimes = List();
        currentSession.times.forEach((t) {
          strTimes.add(DateFormat('hh:mm a MM-dd-yyyy').format(t.toLocal()));
        });
        int sessions = (sharedPreferences.getInt('sessions') ?? 0) + 1;
        sharedPreferences.setStringList('ids_$sessions', currentSession.deviceIds);
        sharedPreferences.setStringList('times_$sessions', strTimes);
        sharedPreferences.setInt('sessions', sessions);
        currentSession = Session();
      });
    } catch(e) {
      debugPrint('not success');
      setState(() {
        _sendingData = false;
        _error = 'There\'s been an error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('error is $_error, ${_error != ''}');
    return new Scaffold(
      appBar: new AppBar(
        title: Text('New Session'),
      ),
      body: _error != '' ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_error),
            RaisedButton(
              child: Text('Retry'),
              onPressed: () {
                sendSession();
              },
            )
          ],
        ),
      ) : _sendingData ? Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(),
            _scanning && currentSession.deviceIds.length > 0 ? Center(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currentSession.deviceIds.length,
                itemBuilder: (ctx, index) {
                  return Text('Connected to device COVID19-${currentSession.deviceIds[index]} on ${DateFormat('hh:mm a MM-dd-yyyy').format(currentSession.times[index].toLocal())}.', textAlign: TextAlign.center,);
                },
              ),
            ) : _scanning ? Text('No devices yet.') : Text('Press the start session button whenever you\'re out, and press stop when you return home. Do not close this app during the session for proper function'),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: RaisedButton(child: Text(_scanning ? 'Stop session' : 'Start session'), onPressed: () async {
                  debugPrint('3: $_shouldStop && $_scanning');
                  try {
                    if(_scanning) {
                      _shouldStop = true;
                      await Wakelock.disable();
                      await _bluetooth.stopScan();
                      _scanning = false;
                      sendSession();
                    }
                    else {
                      await Wakelock.enable();
                      await _bluetooth.startScan(pairedDevices: false);
                      debugPrint("scanning started");
                      _shouldStop = false;
                      setState(() {
                        _scanning = true;
                      });
                    }
                  } on PlatformException catch (e) {
                    debugPrint(e.toString());
                  }
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}