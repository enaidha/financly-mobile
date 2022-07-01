import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/configs/auth_service.dart';
import 'package:finance_plan/configs/flutterfire.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  final _form = GlobalKey<FormState>();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final TextEditingController _editUsernameController = TextEditingController();
  final TextEditingController _editPasswordController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  bool _btnDaftar = false;
  bool _agreement = false;

  _register(name, email, username, password, isGoogle) async {
    UserModel userM = UserModel(name: name, email: email, username: username);

    if (isGoogle) {
      dynamic shouldNavigate =
          await register(userCol: users, user: userM, password: password);
      if (shouldNavigate is bool) {
        var snackbar = SnackBar(
          content: Text(
            'Berhasil mendaftar',
            style: mCardTitleStyle.copyWith(
              fontSize: _sizeConfig.blockHorizontal! * 4,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: mPrimaryColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        String msg = 'Terjadi kesalahan';
        if (shouldNavigate == 'email-already-in-use') {
          msg = "Email telah digunakan";
        }
        var snackbar = SnackBar(
          content: Text(
            msg,
            style: mCardTitleStyle.copyWith(
              fontSize: _sizeConfig.blockHorizontal! * 4,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: mPrimaryColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } else {
      if (_form.currentState!.validate()) {
        bool shouldNavigate =
            await register(userCol: users, user: userM, password: password);
        if (shouldNavigate) {
          var snackbar = SnackBar(
            content: Text(
              'Berhasil mendaftar',
              style: mCardTitleStyle.copyWith(
                fontSize: _sizeConfig.blockHorizontal! * 4,
                fontWeight: FontWeight.w400,
              ),
            ),
            backgroundColor: mPrimaryColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          Navigator.pushReplacementNamed(context, '/login');
        }

        var snackbar = SnackBar(
          content: Text(
            'Berhasil mendaftar',
            style: mCardTitleStyle.copyWith(
              fontSize: _sizeConfig.blockHorizontal! * 4,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: mPrimaryColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);

        Navigator.pushNamed(context, '/login');
      }
    }
  }

  _googleRegister() async {
    AuthServices services = AuthServices();
    try {
      await services.signInwithGoogle();
      User? user = FirebaseAuth.instance.currentUser;

      String newUsername = user!.displayName!.replaceAll(' ', '');
      newUsername = newUsername.toLowerCase();

      _register(user.displayName, user.email, newUsername, newUsername, true);
    } catch (e) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: _sizeConfig.screenWidth,
          height: _sizeConfig.screenHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(_sizeConfig.blockHorizontal! * 6),
                      child: Image.asset(
                        'assets/images/arrow-left.png',
                        width: _sizeConfig.blockHorizontal! * 4,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _sizeConfig.blockVertical! * 2,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: _sizeConfig.blockHorizontal! * 6),
                      child: Text(
                        'Register',
                        style: mInputStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 10,
                            color: mPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _sizeConfig.blockVertical! * 2,
                  ),
                  Container(
                    height: _sizeConfig.blockVertical! * 8,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 1.4,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: TextFormField(
                      controller: _editNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintText: 'Nama',
                          hintStyle: mSubtitleStyle.copyWith(
                              fontSize: _sizeConfig.blockVertical! * 2.6,
                              fontWeight: FontWeight.w400),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: mBorderColor,
                                  style: BorderStyle.solid)),
                          errorStyle: mDangerTextStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 3,
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap diisi.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    height: _sizeConfig.blockVertical! * 8,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 1.4,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: TextFormField(
                      controller: _editEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: mSubtitleStyle.copyWith(
                              fontSize: _sizeConfig.blockVertical! * 2.6,
                              fontWeight: FontWeight.w400),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: mBorderColor,
                                  style: BorderStyle.solid)),
                          errorStyle: mDangerTextStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 3,
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap diisi.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    height: _sizeConfig.blockVertical! * 8,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 1.4,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: TextFormField(
                      controller: _editUsernameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: mSubtitleStyle.copyWith(
                              fontSize: _sizeConfig.blockVertical! * 2.6,
                              fontWeight: FontWeight.w400),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: mBorderColor,
                                  style: BorderStyle.solid)),
                          errorStyle: mDangerTextStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 3,
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap diisi.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    height: _sizeConfig.blockVertical! * 8,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 1.4,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: TextFormField(
                      controller: _editPasswordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: mSubtitleStyle.copyWith(
                              fontSize: _sizeConfig.blockVertical! * 2.6,
                              fontWeight: FontWeight.w400),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: mBorderColor,
                                  style: BorderStyle.solid)),
                          errorStyle: mDangerTextStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 3,
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap diisi.';
                        }
                        return null;
                      },
                    ),
                  ),
                  CheckboxListTile(
                    title: RichText(
                      text: TextSpan(
                          text: 'By signing up, you agree to ',
                          style: mInputStyle.copyWith(
                              color: Colors.black,
                              fontSize: _sizeConfig.blockHorizontal! * 3.6,
                              fontWeight: FontWeight.w200),
                          children: [
                            TextSpan(
                                text: 'Terms of Service ',
                                style: mInputStyle.copyWith(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontSize:
                                        _sizeConfig.blockHorizontal! * 3.6,
                                    fontWeight: FontWeight.w200),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print('term of service');
                                  }),
                            TextSpan(
                              text: 'and ',
                              style: mInputStyle.copyWith(
                                  color: Colors.black,
                                  fontSize: _sizeConfig.blockHorizontal! * 3.6,
                                  fontWeight: FontWeight.w200),
                            ),
                            TextSpan(
                                text: 'Privacy Policy.',
                                style: mInputStyle.copyWith(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontSize:
                                        _sizeConfig.blockHorizontal! * 3.6,
                                    fontWeight: FontWeight.w200),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print('privacy policy');
                                  })
                          ]),
                    ),
                    subtitle: !_agreement && _btnDaftar
                        ? Text(
                            'Harap setujui terlebih dahulu!',
                            style: mInputStyle.copyWith(
                                color: Colors.red,
                                fontSize: _sizeConfig.blockHorizontal! * 3.6,
                                fontWeight: FontWeight.w200),
                          )
                        : null,
                    value: _agreement,
                    onChanged: (newValue) {
                      setState(() {
                        _agreement = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, //  <-- leading Checkbox
                  ),
                  Container(
                    width: _sizeConfig.screenWidth,
                    height: _sizeConfig.blockHorizontal! * 14,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 1.4,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: _sizeConfig.blockVertical! * 0.8,
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _btnDaftar = true;
                        });
                        if (_agreement) {
                          _register(
                              _editNameController.text,
                              _editEmailController.text,
                              _editUsernameController.text,
                              _editPasswordController.text,
                              false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: mPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Daftar',
                        style: mInputStyle.copyWith(
                            fontSize: _sizeConfig.btnTextSize,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.symmetric(
                  //       vertical: _sizeConfig.blockVertical! * 0.8),
                  //   child: Text(
                  //     'Atau daftar dengan',
                  //     textAlign: TextAlign.center,
                  //     style: mInputStyle.copyWith(
                  //         fontSize: _sizeConfig.blockHorizontal! * 3.6,
                  //         fontWeight: FontWeight.w200),
                  //   ),
                  // ),
                  // Container(
                  //   width: _sizeConfig.screenWidth,
                  //   height: _sizeConfig.blockVertical! * 8,
                  //   padding: EdgeInsets.symmetric(
                  //     vertical: _sizeConfig.blockVertical! * 0.8,
                  //     horizontal: _sizeConfig.blockHorizontal! * 6,
                  //   ),
                  //   child: ElevatedButton.icon(
                  //     icon: const Icon(FontAwesomeIcons.google),
                  //     onPressed: () {
                  //       _googleRegister();
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       primary: mDangerColor,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(50),
                  //       ),
                  //     ),
                  //     label: Text(
                  //       'Daftar dengan Google',
                  //       style: mInputStyle.copyWith(
                  //           fontSize: _sizeConfig.blockVertical! * 2.6,
                  //           fontWeight: FontWeight.w400,
                  //           color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //     top: _sizeConfig.blockVertical! * 2,
                  //   ),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.pushNamedAndRemoveUntil(
                  //           context, '/login', (route) => false);
                  //     },
                  //     child: RichText(
                  //       text: TextSpan(
                  //           text: 'Sudah punya akun?',
                  //           style: mInputStyle.copyWith(
                  //             fontSize: _sizeConfig.blockHorizontal! * 4,
                  //             fontWeight: FontWeight.w300,
                  //           ),
                  //           children: [
                  //             TextSpan(
                  //               text: 'Login sekarang',
                  //               style: mInputStyle.copyWith(
                  //                 fontSize: _sizeConfig.blockHorizontal! * 4,
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             )
                  //           ]),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
