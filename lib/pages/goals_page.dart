import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  String? uuid = '';
  final _form = GlobalKey<FormState>();
  final TextEditingController _editNamaController = TextEditingController();
  final TextEditingController _editWaktuController = TextEditingController();
  final TextEditingController _editNominalController = TextEditingController();
  final TextEditingController _editKetController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime now = DateTime.now();
  DateTime? _selectedDate;

  getPref() async {
    SharedPreferences pref = preferences;
    pref = pref;
    print('user_id : ' + pref.getString('user_id')!);
    print('name : ' + pref.getString('name')!);
    setState(() {
      uid = pref.getString('user_id')!;
    });
  }

  int _countDeadline(String deadline) {
    int hasil = 0;
    var date = DateTime.now();
    String now = date.toString().split('.')[0];
    int currentYear = int.parse(now.split('-')[0]);
    int currentMonth = int.parse(now.split('-')[1]);
    print('current year : $currentYear');
    print('current month : $currentMonth');
    int deadlineYear = int.parse(_editWaktuController.text.split('-')[0]);
    int deadlineMonth = int.parse(_editWaktuController.text.split('-')[1]);

    int yearResult = 0;
    int monthResult = 0;
    if ((deadlineMonth - currentMonth) <= 0) {
      deadlineYear -= 1;
      monthResult = (deadlineMonth + 12) - currentMonth;
      yearResult = deadlineYear - currentYear;
    } else {
      monthResult = deadlineMonth - currentMonth;
      yearResult = deadlineYear - currentYear;
    }

    if (yearResult > 0) {
      hasil = (yearResult * 12) + monthResult;
    } else {
      hasil = monthResult;
    }

    return hasil;
  }

  submit() {
    if (_form.currentState!.validate()) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      print('submit');
      int deadlineResult = _countDeadline(_editWaktuController.text);
      print('deadline result : $deadlineResult');
      CollectionReference goals = users.doc(uid).collection('goals');
      print('date : ' +
          dateFormat.parse(now.toString().substring(0, 10)).toString());
      goals.add({
        'nama': _editNamaController.text,
        'deadline': _editWaktuController.text,
        'deadline_bulan': deadlineResult,
        'target': int.parse(_editNominalController.text),
        'keterangan': _editKetController.text,
        'progres': 0.0,
        'status': 'onprogress',
        'created_at': now.toString().split('-')[0] +
            '-' +
            now.toString().split('-')[1] +
            '-' +
            now.toString().split('-')[2],
      }).then((value) async {
        uuid = value.id;
        print("uuid : " + uuid.toString());
        print('is_production : ' + isProduction.toString());

        var targetMonth =
            int.parse(_editNominalController.text) / deadlineResult;
        var date = DateTime.now();
        int appendMonth = 1;
        for (var i = 0; i < deadlineResult; i++) {
          var getMonthTarget = i + 1;
          print("xxxxx Bulan ke : " + getMonthTarget.toString());
          print("xxxxx Jumlah : " + targetMonth.toString());

          var pembayaranKe = 'Pembayaran ke-' + getMonthTarget.toString();
          var deadlineNextMonth =
              DateTime(date.year, date.month + appendMonth, 01);
          String newDeadlineNextMonth =
              deadlineNextMonth.toString().split('-')[0] +
                  '-' +
                  deadlineNextMonth.toString().split('-')[1] +
                  '-01';
          var jumlahGoals = targetMonth;
          var status = 'undone';
          int notifId = date.year +
              date.month +
              date.day +
              date.hour +
              date.minute +
              date.second +
              date.millisecond +
              date.microsecond +
              i;
          var val = await users
              .doc(uid)
              .collection('goals')
              .doc(uuid)
              .collection('checklistgoals')
              .add({
            'pembayaran': pembayaranKe,
            'jumlah_goals_bulanan': jumlahGoals,
            'deadline_bulanan': newDeadlineNextMonth,
            'status_pembayaran': status,
            'notif_id': notifId
          });
          //add notif to status bar
          // await flutterLocalNotificationsPlugin.zonedSchedule(
          //     notifId,
          //     pembayaranKe + " " + _editNamaController.text,
          //     "Jangan lupa bahwa " + pembayaranKe + " tinggal 3 hari lagi",
          //     tz.TZDateTime(
          //             tz.local,
          //             deadlineNextMonth.year,
          //             deadlineNextMonth.month,
          //             deadlineNextMonth.day,
          //             date.hour,
          //             date.minute,
          //             date.second)
          //         .subtract(const Duration(days: 3)),
          //     NotificationDetails(
          //         android: AndroidNotificationDetails(val.id, "Pembayaran",
          //             channelDescription: "Pengingat pembayaran dalam 3 hari")),
          //     androidAllowWhileIdle: true,
          //     uiLocalNotificationDateInterpretation:
          //         UILocalNotificationDateInterpretation.absoluteTime);
          //add notif to firebase and show in base_screen
          if (isProduction) {
            var notif = await users.doc(uid).collection('notif').add({
              'show': Timestamp.fromDate(DateTime(
                      deadlineNextMonth.year,
                      deadlineNextMonth.month,
                      deadlineNextMonth.day,
                      date.hour,
                      date.minute,
                      date.second)
                  .subtract(const Duration(days: 3))),
              'title': pembayaranKe + " " + _editNamaController.text,
              'body':
                  "Jangan lupa bahwa " + pembayaranKe + " tinggal 3 hari lagi",
              'goals_id': uuid,
              'notif_id': notifId
            });
          } else {
            var notif = await users
                .doc(uid)
                .collection('notif')
                .doc(notifId.toString())
                .set({
              'show': Timestamp.fromDate(DateTime(date.year, date.month,
                      date.day, date.hour, date.minute, date.second)
                  .add(Duration(minutes: 1 + i))),
              'title': pembayaranKe + " " + _editNamaController.text,
              'body':
                  "Jangan lupa bahwa " + pembayaranKe + " tinggal 3 hari lagi",
              'goals_id': uuid,
              'notif_id': notifId
            });
          }
          appendMonth++;
        }

        _editNamaController.clear();
        _editWaktuController.clear();
        _editNominalController.clear();
        _editKetController.clear();

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

        Navigator.pop(context);
      });
    } else {
      print('submit else');
    }
  }

  Future<void> _datePicker({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
      locale: localeObj,
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
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
        child: SizedBox(
          width: _sizeConfig.screenWidth,
          height: _sizeConfig.screenHeight,
          child: ListView(
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
                  controller: _editNamaController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: 'Nama goals',
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
                height: _sizeConfig.blockVertical! * 8,
                margin: EdgeInsets.only(
                  top: _sizeConfig.blockVertical! * 4,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _sizeConfig.blockHorizontal! * 6,
                ),
                child: TextFormField(
                  controller: _editWaktuController,
                  keyboardType: TextInputType.datetime,
                  maxLength: 7,
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: 'Waktu',
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
                  onTap: () async {
                    await _datePicker(context: context);
                    print('selected date : $_selectedDate');
                    setState(() => _editWaktuController.text =
                        _selectedDate.toString().substring(0, 7));
                    // DatePicker.showDatePicker(context,
                    //     showTitleActions: true,
                    //     minTime: DateTime(now.year, now.month, now.day),
                    //     maxTime: DateTime(now.year + 5, 12, 1),
                    //     onChanged: (date) {
                    //   print('change $date');
                    // }, onConfirm: (date) {
                    //   print('confirm $date');
                    //   setState(() => _editWaktuController.text =
                    //       date.toString().substring(0, 10));
                    // }, currentTime: DateTime.now(), locale: LocaleType.id);
                  },
                ),
              ),
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
                height: _sizeConfig.blockVertical! * 14,
                margin: EdgeInsets.only(
                  top: _sizeConfig.blockVertical! * 4,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _sizeConfig.blockHorizontal! * 6,
                ),
                child: TextFormField(
                  controller: _editKetController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                      hintText: 'Keterangan',
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
                    print('user id goals: $uid');
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
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      title: Text(
        'Goals',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
    );
  }
}
