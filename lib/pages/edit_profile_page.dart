import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:finance_plan/configs/flutterfire.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:finance_plan/pages/base_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final SizeConfig _sizeConfig = SizeConfig();

  bool _isLoading = false;

  SharedPreferences? pref;
  String? uid = '';
  String? name = '';
  String? username = '';
  String? email = '';
  String? photoUrl = '';
  String? password = '';
  User? user = FirebaseAuth.instance.currentUser;

  final _form = GlobalKey<FormState>();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final TextEditingController _editUsernameController = TextEditingController();
  final TextEditingController _editPasswordController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  getPref() async {
    SharedPreferences pref = preferences;
    pref = pref;
    print('user_id : ' + pref.getString('user_id')!);
    print('named : ' + pref.getString('name')!);
    setState(() {
      uid = pref.getString('user_id')!;
      name = pref.getString('name')!;
      username = pref.getString('username')!;
      email = pref.getString('email')!;
      photoUrl =
          pref.containsKey('photo_url') ? pref.getString('photo_url') : '-';
      /* password = preferences.getString('password')!; */
    });
  }

  /* getUserData() async {
    DocumentSnapshot getUserLog = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      print('pass : ' + getUserLog['password']);
      name = getUserLog['name'];
      username = getUserLog['username'];
      email = getUserLog['email'];
      password = getUserLog['password'];
    });
  } */

  showDialogEmpty(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Oke"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Pesan"),
      content: Text("Data Tidak Boleh Kosong !"),
      actions: [
        cancelButton,
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

  showDialogSuccess(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Oke"),
      onPressed: () {
        /* Navigator.pop(context); */
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BaseScreen()),
            (Route<dynamic> route) => false);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Pesan"),
      content: Text("Berhasil Memperbarui Data !"),
      actions: [
        cancelButton,
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
    // getUserData();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore fFireStore = FirebaseFirestore.instance;
    CollectionReference crUsers = fFireStore.collection('users');
    _sizeConfig.init(context);

    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
        child: SizedBox(
          width: _sizeConfig.screenWidth,
          height: _sizeConfig.screenHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: Text(
                      'User Account',
                      style: mTitleStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            top: _sizeConfig.blockVertical! * 4,
                            bottom: _sizeConfig.blockVertical! * 4,
                          ),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(60),
                            padding: EdgeInsets.all(5.0),
                            color: mPrimaryColor,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              child: Container(
                                  height: 65.0,
                                  width: 70.0,
                                  /* child: _profilePicture == 'ic-profile-the-skill.png'
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
                                      ? Image.network(
                                          photoUrl!,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.asset(
                                          'assets/images/ic-profile.png',
                                          fit: BoxFit.fill,
                                        )),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sizeConfig.blockHorizontal! * 3,
                        ),
                        TextButton(
                          child: Text('Edit Photo Profil',
                              style: mSubtitleStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: _sizeConfig.blockVertical! * 8,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 0.5,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: TextFormField(
                      controller: _editNameController..text = '${name}',
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintText: 'Nama',
                          hintStyle: mSubtitleStyle.copyWith(
                              fontSize: _sizeConfig.blockVertical! * 2.6,
                              fontWeight: FontWeight.w400),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: mPrimaryColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: mPrimaryColor),
                          ),
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
                    width: _sizeConfig.screenWidth,
                    height: _sizeConfig.blockVertical! * 8,
                    margin: EdgeInsets.only(
                      top: _sizeConfig.blockVertical! * 2,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: _sizeConfig.blockVertical! * 0.8,
                      horizontal: _sizeConfig.blockHorizontal! * 6,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        /* _register(
                            _editNameController.text,
                            _editEmailController.text,
                            _editUsernameController.text,
                            _editPasswordController.text,
                            false); */
                        if (_editNameController.text.isNotEmpty) {
                          // crUsers.doc(uid).update({
                          //   'email': _editEmailController.text,
                          //   'name': _editNameController.text,
                          //   'username': _editUsernameController.text,
                          // });
                          String photoUrl =
                              'https://cdn0-production-images-kly.akamaized.net/E7ECDOvmxWoRpO6evoQua66zy38=/1200x900/smart/filters:quality(75):strip_icc():format(jpeg)/kly-media-production/medias/2364595/original/053269800_1542442403-012225100_1537534716-Kurt_Cobain1.jpg';
                          updateProfilePhoto(photoUrl);
                          updateAccount(_editNameController.text);
                          showDialogSuccess(context);
                        } else {
                          print("Pesan : Kolom Tidak Boleh Kosong");
                          setState(() {
                            _isLoading = false;
                          });
                          showDialogEmpty(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: mPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: mInputStyle.copyWith(
                            fontSize: _sizeConfig.blockVertical! * 2,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      centerTitle: true,
      title: Text(
        'Edit Profile',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 4,
        ),
      ),
    );
  }
}
