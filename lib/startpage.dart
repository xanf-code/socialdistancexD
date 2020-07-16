import 'welcome_screen.dart';
import 'main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://testing.icanhelp.us:8080/',
        validateStatus: (_) => true
      ),
    );
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getBool('first_run') ?? false) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => IndexPage()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => WelcomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.red)),
    );
  }
}
