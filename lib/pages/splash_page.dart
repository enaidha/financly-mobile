import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/configs/local_notification.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/pages/base_screen.dart';
import 'package:finance_plan/pages/login_page.dart';
import 'package:finance_plan/widgtes/header_start.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  bool _isLogin = false;

  _initialPref() async {
    final SharedPreferences prefs = preferences;

    if (prefs.getString('user_id') != null) {
      // Sudah pernah login
      setState(() => _isLogin = true);
    }

    if (_isLogin) {
      _loadWidget(_gohomepage);
    } else {
      _loadWidget(_gologinpage);
    }
  }

  @override
  void initState() {
    super.initState();
    _initialPref();
    loadData();
  }

  _loadWidget(goto) async {
    var _duration = const Duration(seconds: 5);
    return Timer(_duration, goto);
  }

  void _gologinpage() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _gohomepage() {
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  int _counterValue = 0;

  void loadData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      body: Container(
        width: _sizeConfig.screenWidth,
        height: _sizeConfig.screenHeight,
        margin: EdgeInsets.only(
          left: _sizeConfig.marginHorizontalSize!,
          right: _sizeConfig.marginHorizontalSize!,
        ),
        color: mBackgroundColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: _sizeConfig.blockHorizontal! * 60,
                  height: _sizeConfig.blockHorizontal! * 60,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
