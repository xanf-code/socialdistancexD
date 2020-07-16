import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'main.dart';

class Session {
  
  List<String> deviceIds = List();
  List<DateTime> times = List();
  bool uploadSuccess = false;

  List<String> strTimes = List();

  void add(String deviceId) {
    if(!deviceIds.contains(deviceId)) {
      deviceIds.add(deviceId);
      times.add(DateTime.now().toUtc());
    }
  }

  Future<void> send() async {

    if(deviceIds.length == 0) return;

    String strIds = deviceIds[0];
    for(int i = 1; i < deviceIds.length; i++) {
      strIds += ',' + deviceIds[i];
    }

    String strTimes = '${times[0].millisecondsSinceEpoch}';
    for(int i = 1; i < deviceIds.length; i++) {
      strIds += ',${times[i].millisecondsSinceEpoch}';
    }

    Map<String, String> data = {
      "ids" : strIds,
      "times" : strTimes
    };
    debugPrint('data: $data');
    Response res = await dio.post('/submitSession/' + sharedPreferences.getString('my_id'), data: FormData.fromMap(data));
    if(res.data['success'] == true) {
      return;
    } else {
      throw new ErrorDescription('Server side error, try again.');
    }
  }

}