import 'main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class SettingsPage extends StatelessWidget {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text('Your phone should be named ${sharedPreferences.getString('my_id')}'),
              RaisedButton(
                child: Text('Report a positive COVID-19 diagnosis'),
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now().subtract(Duration(days: 14)),
                      maxTime: DateTime.now().add(Duration(seconds: 1)),
                      onConfirm: (date) {
                        print('confirm $date');
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Report Diagnosis'),
                                content: Text('Are you sure you want to report a positive COVID-19 diagnosis on ${DateFormat('hh:mm a MM-dd-yyyy').format(date)}?'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Confirm'),
                                    onPressed: () {
                                      () async {
                                        Response res = await dio.post('/positive/${sharedPreferences.getString('my_id')}', data: FormData.fromMap({"time":date.toUtc().millisecondsSinceEpoch}));
                                        if(res.data['success'] == true) {
                                          scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Successfully reported positive COVID-19 diagnosis')));
                                        } else {
                                          scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Error: ${res.data['error'] ?? 'Unknown Error'}')));
                                        }
                                      } ();
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            }
                        );
                      }, currentTime: DateTime.now(), locale: LocaleType.en);

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
