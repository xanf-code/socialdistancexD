import 'main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

enum LoadState {
  loading, success, error
}

class AlertPage extends StatefulWidget {
  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  
  LoadState loadState = LoadState.loading;
  String errStr = '';
  List<Widget> children = List();

  @override
  void initState() {
    super.initState();
    load();
  }
  
  void load() async {
    children = List();
    setState(() {
      loadState = LoadState.loading;
    });
    
    Response res = await dio.get("/alerts/${sharedPreferences.getString('my_id')}");

    try {
      if(res.data['success'] == true) {
        if(res.data['ids'] == '') {
          children.add(Text('No contact yet'));
          setState(() {
            loadState = LoadState.success;
          });
          return;
        }
        for(int i = 0; i < res.data['ids'].length; i++) {
          debugPrint('millisecionds since epoch: ${res.data['times']}');
          debugPrint('for dart: ${DateTime.now().toUtc().millisecondsSinceEpoch}');
          DateTime dt = DateTime.fromMillisecondsSinceEpoch((int.parse(res.data['times'])).floor(), isUtc: true).toLocal();
          children.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Contact with COVID19-${res.data['ids'][i]}'),
              Text('at  ${DateFormat('hh:mm a MM-dd-yyyy').format(dt)}')
            ],
          ));
        }
        setState(() {
          loadState = LoadState.success;
        });
      } else {
        setState(() {
          loadState = LoadState.error;
          errStr = 'Error: ${res.data['error'] ?? 'Unknown Error'}';
        });
      }
    } catch(e) {
      setState(() {
        loadState = LoadState.error;
        errStr = 'Error: ${res.data['error'] ?? 'Unknown Error'}';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alerts'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => load(),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loadState == LoadState.success ? ListView(
            children: children..insert(0, Text('Positive COVID-19 Contact:')),
          ) : loadState == LoadState.error ? Column(
            children: <Widget>[
              Text('Error loading: $errStr'),
              RaisedButton(
                child: Text('Try Again'),
                onPressed: () {
                  load();
                },
              )
            ],
          ) : CircularProgressIndicator(),
        ),
      )
    );
  }
}
