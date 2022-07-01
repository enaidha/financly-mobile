import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class PemasukanPage extends StatefulWidget {
  const PemasukanPage({Key? key}) : super(key: key);

  @override
  _PemasukanPageState createState() => _PemasukanPageState();
}

class _PemasukanPageState extends State<PemasukanPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  final _form = GlobalKey<FormState>();
  final TextEditingController _editNominalController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  getPref() {
    SharedPreferences pref = preferences;
    pref = pref;
    print('user_id : ' + pref.getString('user_id')!);
    print('name : ' + pref.getString('name')!);
    setState(() {
      uid = pref.getString('user_id')!;
    });
  }

  submit() async {
    if (_form.currentState!.validate()) {
      var date = DateTime.now();
      String now = date.toString().split('.')[0];
      String month = now.split('-')[1];
      String year = now.split('-')[0];

      CollectionReference tabungan = users.doc(uid).collection('tabungan');
      CollectionReference laporan = users.doc(uid).collection('laporan');
      var goals = users
          .doc(uid)
          .collection('goals')
          .where('status', isEqualTo: 'onprogress');
      num currentSaldo = 0;
      tabungan.add({
        'saldo_tabungan': int.parse(_editNominalController.text),
        'created_at': now
      });

      /* Get current tabungan */
      await tabungan.get().then((value) {
        if (value.size > 0) {
          for (var i = 0; i < value.size; i++) {
            setState(() {
              currentSaldo += value.docs.elementAt(i)['saldo_tabungan'];
            });
          }
        }
      });
      print('current saldo : $currentSaldo');
      /* End */

      /* Update Current saldo */
      await users.doc(uid).set({'current_saldo': currentSaldo});
      // await users.doc(uid)
      /* End */

      /* Progres goals */
      // await goals.get().then((value) {
      //   if (value.size > 0) {
      //     if (currentSaldo >= value.docs.elementAt(0)['target']) {
      //       // Update status goals
      //       users
      //           .doc(uid)
      //           .collection('goals')
      //           .doc(value.docs.first.id)
      //           .update({'status': 'done'});
      //     }
      //   }
      // });
      /* End Progres goals */

      /* Adding laporan */
      await laporan.add({
        'judul': 'Pemasukan',
        'is_pemasukan': true,
        'nominal': num.parse(_editNominalController.text),
        'created_at': now,
        'month_created': month,
        'year_created': year,
      });
      /* End */

      _editNominalController.clear();

      var snackbar = SnackBar(
        content: Text(
          'Berhasil',
          style: mCardTitleStyle.copyWith(
            fontSize: _sizeConfig.blockHorizontal! * 4,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: mPrimaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      // tabungan.get().then((value) {
      //   if (value.size == 0) {
      //   } else {
      //     currentSaldo = value.docs.elementAt(0)['saldo_tabungan'];
      //     currentSaldo += int.parse(_editNominalController.text);
      //     tabungan
      //         .doc(value.docs.elementAt(0).id)
      //         .update({'saldo_tabungan': currentSaldo, 'updated_at': now});
      //   }

      //   _editNominalController.clear();

      //   var snackbar = SnackBar(
      //     content: Text(
      //       'Berhasil',
      //       style: mCardTitleStyle.copyWith(
      //         fontSize: _sizeConfig.blockHorizontal! * 4,
      //         fontWeight: FontWeight.w400,
      //       ),
      //     ),
      //     backgroundColor: mPrimaryColor,
      //   );
      //   ScaffoldMessenger.of(context).showSnackBar(snackbar);

      //   Navigator.pop(context);
      // });
    }
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
      body: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _sizeConfig.blockVertical! * 8,
              margin: EdgeInsets.only(
                top: _sizeConfig.blockVertical! * 4,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: _sizeConfig.blockHorizontal! * 6,
              ),
              child: TextFormField(
                controller: _editNominalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: 'Masukkan nominal',
                    hintStyle: mSubtitleStyle.copyWith(
                        fontSize: _sizeConfig.blockVertical! * 2.6,
                        fontWeight: FontWeight.w400),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 1.4,
                            color: mPrimaryColor,
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
              width: _sizeConfig.screenWidth,
              height: _sizeConfig.blockVertical! * 8,
              margin: EdgeInsets.only(
                top: _sizeConfig.blockVertical! * 1.4,
              ),
              padding: EdgeInsets.symmetric(
                vertical: _sizeConfig.blockVertical! * 0.8,
                horizontal: _sizeConfig.blockHorizontal! * 6,
              ),
              child: ElevatedButton(
                onPressed: () {
                  print('user id : $uid');
                  submit();
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
                      fontSize: _sizeConfig.blockVertical! * 2.6,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      title: Text(
        'Pemasukan',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
    );
  }
}
