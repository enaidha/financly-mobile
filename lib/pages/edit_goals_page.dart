import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:finance_plan/models/user_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/timezone.dart' as tz;

class EditGoalsPage extends StatefulWidget {
  const EditGoalsPage({Key? key}) : super(key: key);

  @override
  _EditGoalsPageState createState() => _EditGoalsPageState();
}

class _EditGoalsPageState extends State<EditGoalsPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  final _form = GlobalKey<FormState>();
  bool _editNama = false;
  bool _editWaktu = false;
  bool _editTarget = false;
  final TextEditingController _editNamaController = TextEditingController();
  final TextEditingController _editWaktuController = TextEditingController();
  final TextEditingController _editNominalController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime now = DateTime.now();
  String _newNama = '';
  String _nominal = '0';
  DateTime? _selectedDate;

  getPref() {
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

  submit(String goalsId) {
    if (_form.currentState!.validate()) {
      final args = ModalRoute.of(context)!.settings.arguments as GoalsArgument;
      List<int> yearMonth = [
        int.parse(args.deadline!.substring(0, 7).split('-')[0]),
        int.parse(args.deadline!.substring(0, 7).split('-')[1])
      ];
      print("Waktu : " + _editWaktuController.text);
      DateTime dateTarget = DateTime(yearMonth[0], yearMonth[1]);
      var date = DateTime.now();
      String now = date.toString().split('.')[0];
      int deadlineResult = _countDeadline(_editWaktuController.text);
      print('deadline result : $deadlineResult');
      CollectionReference goals = users.doc(uid).collection('goals');

      goals.doc(goalsId).collection('checklistgoals').get().then((value) async {
        int dibayar = 0;
        int belumDibayar = 0;
        num totalTerbayar = 0;
        num totalBelumDibayar = 0;
        // Menghapus item
        for (var i = 0; i < value.size; i++) {
          if (value.docs.elementAt(i).get('status_pembayaran') == 'done') {
            dibayar++;
            totalTerbayar +=
                value.docs.elementAt(i).get('jumlah_goals_bulanan');
          } else {
            belumDibayar++;
            totalBelumDibayar +=
                value.docs.elementAt(i).get('jumlah_goals_bulanan');
          }
        }

        // Generate checklist item yg baru
        // var targetMonth = int.parse(_editNominalController.text) /
        //     (deadlineResult - belumDibayar);
        var targetMonth =
            (int.parse(_editNominalController.text) - totalTerbayar) /
                (deadlineResult - dibayar);
        int appendMonth = 1;
        // int result = deadlineResult;
        int result = deadlineResult - dibayar;

        print((int.parse(_editNominalController.text) - totalTerbayar));

        if (result > 0) {
          print('result > 0 is true');
          if ((int.parse(_editNominalController.text) - totalTerbayar) > 0) {
            for (var i = 0; i < value.size; i++) {
              if (value.docs.elementAt(i).get('status_pembayaran') != 'done') {
                await users
                    .doc(uid)
                    .collection('notif')
                    .doc(value.docs.elementAt(i).get('notif_id'))
                    .delete();
                await flutterLocalNotificationsPlugin
                    .cancel(value.docs.elementAt(i).get('notif_id'));
                goals
                    .doc(goalsId)
                    .collection('checklistgoals')
                    .doc(value.docs.elementAt(i).id)
                    .delete();
              }
            }

            int startPembayaran = dibayar;
            date = DateTime(date.year, date.month + startPembayaran, date.day);
            var now = DateTime.now();
            for (var i = 0; i < result; i++) {
              var getMonthTarget = i + 1;
              startPembayaran++;
              print("xxxxx Bulan ke : " + startPembayaran.toString());
              print("xxxxx Jumlah : " + targetMonth.toString());

              var pembayaranKe = 'Pembayaran ke-' + startPembayaran.toString();
              var deadlineNextMonth =
                  DateTime(date.year, date.month + appendMonth, 01);
              String newDeadlineNextMonth =
                  deadlineNextMonth.toString().split('-')[0] +
                      '-' +
                      deadlineNextMonth.toString().split('-')[1] +
                      '-01';
              var jumlahGoals = targetMonth;
              var status = 'undone';
              int notifId = now.year +
                  now.month +
                  now.day +
                  now.hour +
                  now.minute +
                  now.second +
                  now.millisecond +
                  now.microsecond +
                  i;
              var val =
                  await goals.doc(goalsId).collection('checklistgoals').add({
                'pembayaran': pembayaranKe,
                'jumlah_goals_bulanan': jumlahGoals,
                'deadline_bulanan': newDeadlineNextMonth,
                'status_pembayaran': status,
                'notif_id': notifId
              });

              if (isProduction) {
                await users.doc(uid).collection('notif').add({
                  'show': Timestamp.fromDate(DateTime(
                          deadlineNextMonth.year,
                          deadlineNextMonth.month,
                          deadlineNextMonth.day,
                          now.hour,
                          now.minute,
                          now.second)
                      .subtract(const Duration(days: 3))),
                  'title': pembayaranKe + " " + _editNamaController.text,
                  'body': "Jangan lupa bahwa " +
                      pembayaranKe +
                      " tinggal 3 hari lagi",
                  'goals_id': goalsId,
                  'notif_id': notifId
                });
              } else {
                await users
                    .doc(uid)
                    .collection('notif')
                    .doc(notifId.toString())
                    .set({
                  'show': Timestamp.fromDate(DateTime(now.year, now.month,
                          now.day, now.hour, now.minute, now.second)
                      .add(Duration(minutes: 1 + i))),
                  'title': pembayaranKe + " " + _editNamaController.text,
                  'body': "Jangan lupa bahwa " +
                      pembayaranKe +
                      " tinggal 3 hari lagi",
                  'goals_id': goalsId,
                  'notif_id': notifId
                });
              }
              appendMonth++;
            }

            goals.doc(goalsId).update({
              'nama': _editNama ? _newNama : _editNamaController.text,
              'deadline': _editWaktu
                  ? _selectedDate.toString()
                  : _editWaktuController.text.toString().substring(0, 7),
              'deadline_bulan': deadlineResult,
              'target': _editTarget
                  ? int.parse(_nominal)
                  : int.parse(_editNominalController.text),
              'updated_at': now,
              'progres': (dibayar / deadlineResult) * 100,
              'status': 'onprogress'
            });

            _editNamaController.clear();
            _editWaktuController.clear();
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

            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            print('result > 0 is false');
            _editNamaController.clear();
            _editWaktuController.clear();
            _editNominalController.clear();

            var snackbar = SnackBar(
              content: Text(
                'Target tidak boleh kurang',
                style: mCardTitleStyle.copyWith(
                    fontSize: _sizeConfig.blockHorizontal! * 4,
                    fontWeight: FontWeight.w400,
                    color: mDangerColor),
              ),
              backgroundColor: mPrimaryColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);

            Navigator.pop(context);
          }
        } else {
          print('result > 0 is false');
          _editNamaController.clear();
          _editWaktuController.clear();
          _editNominalController.clear();

          var snackbar = SnackBar(
            content: Text(
              'Deadline tidak boleh di bulan yang sama',
              style: mCardTitleStyle.copyWith(
                  fontSize: _sizeConfig.blockHorizontal! * 4,
                  fontWeight: FontWeight.w400,
                  color: mDangerColor),
            ),
            backgroundColor: mPrimaryColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);

          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _datePicker({
    required BuildContext context,
    String? locale,
  }) async {
    final args = ModalRoute.of(context)!.settings.arguments as GoalsArgument;
    List<int> yearMonth = [
      int.parse(args.deadline!.substring(0, 7).split('-')[0]),
      int.parse(args.deadline!.substring(0, 7).split('-')[1])
    ];
    DateTime dateTarget = DateTime(yearMonth[0], yearMonth[1]);
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate ?? dateTarget,
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
    final args = ModalRoute.of(context)!.settings.arguments as GoalsArgument;
    if (!_editNama) {
      _editNamaController.text = args.title!;
    }
    if (!_editWaktu) {
      _editWaktuController.text = args.deadline!.substring(0, 7);
    }
    if (!_editTarget) {
      _editNominalController.text = args.target!.toString();
    }

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
                  onChanged: (_) {
                    setState(() {
                      _editNama = true;
                      _newNama = _.toString();
                    });
                  },
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
                  maxLength: 10,
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
                    setState(() {
                      if (_selectedDate != null) {
                        if (_selectedDate.toString().length > 4) {
                          _editWaktu = true;
                          _editWaktuController.text =
                              _selectedDate.toString().substring(0, 7);
                        }
                      }
                    });
                    // DatePicker.showDatePicker(context,
                    //     showTitleActions: true,
                    //     minTime: DateTime(now.year, now.month, now.day),
                    //     maxTime: DateTime(now.year + 5, 12, 1),
                    //     onChanged: (date) {
                    //   print('change $date');
                    // }, onConfirm: (date) {
                    //   print('confirm $date');
                    //   setState(() {
                    //     _editWaktu = true;
                    //     _editWaktuController.text =
                    //         date.toString().substring(0, 10);
                    //   });
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
                  onChanged: (_) {
                    setState(() {
                      _editTarget = true;
                      _nominal = _.toString();
                    });
                  },
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
                    print('user id goals: ${args.goalsId}');
                    submit(args.goalsId!);
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
