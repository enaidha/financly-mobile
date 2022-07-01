import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/configs/auth_service.dart';
import 'package:finance_plan/configs/flutterfire.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  final _form = GlobalKey<FormState>();
  final TextEditingController _editEmailController = TextEditingController();
  final TextEditingController _editPasswordController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  _login() async {
    if (_form.currentState!.validate()) {
      bool isValid = await signIn(
          _editEmailController.text, _editPasswordController.text, context);

      if (isValid) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (route) => false);
      } else {
        var snackbar = SnackBar(
          content: Text(
            'Email atau password salah',
            style: mCardTitleStyle.copyWith(
              fontSize: _sizeConfig.blockHorizontal! * 4,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: mDangerColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  _googleSignin() async {
    AuthServices services = AuthServices();
    try {
      await services.signInwithGoogle();
      User? user = FirebaseAuth.instance.currentUser;
      SharedPreferences pref = preferences;

      pref.setString('user_id', user!.uid);
      pref.setString('name', user.displayName!);
      pref.setString('email', user.email!);
      pref.setString('username', user.email!);
      pref.setString('photo_url', user.photoURL!);
      pref.setBool('is_google', true);
      print("xxx ${pref.getString('user_id')}");
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
    } catch (e) {
      print('auth error : ' + e.toString());
      if (e is FirebaseAuthException) {
        var snackbar = SnackBar(
          content: Text(
            e.message!,
            style: mCardTitleStyle.copyWith(
              fontSize: _sizeConfig.blockHorizontal! * 4,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: mDangerColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      var snackbar = SnackBar(
        content: Text(
          'Terjadi kesalahan',
          style: mCardTitleStyle.copyWith(
            fontSize: _sizeConfig.blockHorizontal! * 4,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: mDangerColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
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
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: _sizeConfig.blockHorizontal! * 60,
                    height: _sizeConfig.blockHorizontal! * 60,
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: _sizeConfig.screenWidth,
                  height: _sizeConfig.blockVertical! * 8,
                  padding: EdgeInsets.symmetric(
                    vertical: _sizeConfig.blockVertical! * 0.8,
                    horizontal: _sizeConfig.blockHorizontal! * 6,
                  ),
                  margin:
                      EdgeInsets.only(bottom: _sizeConfig.blockVertical! * 4),
                  child: ElevatedButton.icon(
                    // icon: const Icon(FontAwesomeIcons.google),
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 33,
                    ),
                    onPressed: () {
                      _googleSignin();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: mGrey2Color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    label: Text(
                      'LOGIN WITH GOOGLE',
                      style: mInputStyle.copyWith(
                          fontSize: _sizeConfig.btnTextSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
              ]),
        ),
      ),
      // ),
    );
  }
}
