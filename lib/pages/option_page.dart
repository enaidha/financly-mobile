import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:finance_plan/configs/flutterfire.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionPage extends StatefulWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  final SizeConfig _sizeConfig = SizeConfig();

  SharedPreferences? pref;
  String? uid = '';
  String? name = '';
  String? email = '';
  String? photoUrl = '';

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  getPref() async {
    SharedPreferences pref = preferences;
    pref = pref;
    print('user_id : ' + pref.getString('user_id')!);
    print('name : ' + pref.getString('name')!);
    setState(() {
      uid = pref.getString('user_id')!;
      name = pref.getString('name')!;
      email = pref.getString('email')!;
      photoUrl =
          pref.containsKey('photo_url') ? pref.getString('photo_url') : '-';
    });
  }

  showLogoutDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Tidak"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Ya"),
      onPressed: () {
        flutterLocalNotificationsPlugin.cancelAll();
        logout(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Konfirmasi"),
      content: Text("Anda yakin akan keluar?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _sizeConfig.screenWidth,
            margin: EdgeInsets.only(
              top: _sizeConfig.blockVertical! * 4,
              left: _sizeConfig.blockHorizontal! * 5,
              right: _sizeConfig.blockHorizontal! * 5,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: _sizeConfig.blockHorizontal! * 6,
              vertical: _sizeConfig.blockVertical! * 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: mPrimaryColor,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: Radius.circular(60),
                    padding: EdgeInsets.all(5.0),
                    color: Color(0xFFF6F9F6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: Container(
                          height: 100.0,
                          width: 100.0,
                          /* childchild: _profilePicture == 'ic-profile-the-skill.png'
                            ? Image.asset(
                                'assets/images/ic-profile.png',
                                fit: BoxFit.cover,
                              )
                            : _imageFile != null
                                ? Image.file(
                                    _imageFile,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    "$_baseUrlAvatar" + _profilePicture,
                                    fit: BoxFit.cover,
                                  ), */
                          child: photoUrl!.isNotEmpty && photoUrl != '-'
                              ? Image.network(photoUrl!)
                              : Image.asset(
                                  'assets/images/ic-profile.png',
                                  fit: BoxFit.cover,
                                )),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  child: Text(
                    '${name}',
                    style: mCardTitleStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 4.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 3.0),
                Container(
                  child: Text(
                    '${email}',
                    style: mCardTitleStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 3.5,
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                // Container(
                //   width: _sizeConfig.screenWidth,
                //   height: _sizeConfig.blockVertical! * 8,
                //   margin: EdgeInsets.only(
                //     top: _sizeConfig.blockVertical! * 1.4,
                //   ),
                //   padding: EdgeInsets.symmetric(
                //     vertical: _sizeConfig.blockVertical! * 0.8,
                //     horizontal: _sizeConfig.blockHorizontal! * 6,
                //   ),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       print('user id : $uid');
                //       Navigator.pushNamed(context, '/editProfile');
                //     },
                //     style: ElevatedButton.styleFrom(
                //       primary: Color(0xFFE0C04E),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(50),
                //       ),
                //     ),
                //     child: Text(
                //       'Edit Profile',
                //       style: mInputStyle.copyWith(
                //           fontSize: _sizeConfig.blockVertical! * 1.5,
                //           fontWeight: FontWeight.w400,
                //           color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          // Container(
          //   width: _sizeConfig.screenWidth,
          //   margin: EdgeInsets.only(
          //     top: _sizeConfig.blockVertical! * 1.4,
          //   ),
          //   padding: EdgeInsets.symmetric(
          //     vertical: _sizeConfig.blockVertical! * 0.8,
          //     horizontal: _sizeConfig.blockHorizontal! * 6,
          //   ),
          //   child: Text(
          //     'Pengaturan',
          //     style: mInputStyle.copyWith(
          //       fontSize: _sizeConfig.blockVertical! * 2,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          // SizedBox(height: 15.0),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20),
          //   child: Text('Switch button notifikasi on/off'),
          // ),
          // SizedBox(height: 15.0),
          // Container(
          //   width: _sizeConfig.screenWidth,
          //   margin: EdgeInsets.symmetric(
          //     horizontal: _sizeConfig.blockHorizontal! * 5,
          //   ),
          //   child: GestureDetector(
          //     onTap: () {
          //       showLogoutDialog(context);
          //     },
          //     child: Card(
          //       semanticContainer: true,
          //       clipBehavior: Clip.antiAliasWithSaveLayer,
          //       color: mGrey2Color,
          //       shadowColor: Color(0xffE4E4E4),
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //           side: BorderSide(
          //             color: Color(0xffE4E4E4),
          //           )),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: <Widget>[
          //           Container(
          //             alignment: Alignment.center,
          //             margin: EdgeInsets.symmetric(vertical: 15.0),
          //             child: Text(
          //               "Pilih Nada Dering Notifikasi",
          //               style: mInputStyle.copyWith(
          //                   fontSize: _sizeConfig.blockVertical! * 1.5,
          //                   fontWeight: FontWeight.w600,
          //                   color: Colors.black),
          //               textAlign: TextAlign.center,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(height: 15.0),
          Container(
            width: _sizeConfig.screenWidth,
            margin: EdgeInsets.symmetric(
              horizontal: _sizeConfig.blockHorizontal! * 5,
            ),
            child: GestureDetector(
              onTap: () {
                showLogoutDialog(context);
              },
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Colors.red,
                shadowColor: Color(0xffE4E4E4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Color(0xffE4E4E4),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Keluar",
                        style: mInputStyle.copyWith(
                            fontSize: _sizeConfig.blockVertical! * 1.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      title: Text(
        'Pengaturan',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 4.5,
        ),
      ),
    );
  }
}
