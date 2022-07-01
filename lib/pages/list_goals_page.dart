import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:finance_plan/models/user_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListGoalsPage extends StatefulWidget {
  const ListGoalsPage({Key? key}) : super(key: key);

  @override
  _ListGoalsPageState createState() => _ListGoalsPageState();
}

class _ListGoalsPageState extends State<ListGoalsPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime now = DateTime.now();
  num _currentSaldo = 0;

  getPref() async {
    SharedPreferences pref = preferences;
    pref = pref;
    print('user_id : ' + pref.getString('user_id')!);
    print('name : ' + pref.getString('name')!);
    setState(() {
      uid = pref.getString('user_id')!;
    });
    CollectionReference tabungan = users.doc(uid).collection('tabungan');
    await tabungan.get().then((value) {
      for (var i = 0; i < value.size; i++) {}
    });
    await users.doc(uid).get().then((value) {
      if (value.exists) {
        setState(() {
          _currentSaldo = value.get('current_saldo');
        });
      }
    });
    print('current saldo $_currentSaldo');
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
      body: SafeArea(
        child: uid == null || uid!.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: users
                    .doc(uid)
                    .collection('goals')
                    .orderBy('created_at', descending: false)
                    .snapshots(),
                builder: (context, snapGoals) {
                  if (snapGoals.hasData) {
                    print('size : ${snapGoals.data!.size}');
                    if (snapGoals.data!.size > 0) {
                      return ListView(
                        children: List.generate(
                          snapGoals.data!.size,
                          (i) => _goalsLayout(
                              index: i,
                              title:
                                  snapGoals.data!.docs.elementAt(i).get('nama'),
                              target: snapGoals.data!.docs
                                  .elementAt(i)
                                  .get('target')
                                  .toString(),
                              status: snapGoals.data!.docs
                                  .elementAt(i)
                                  .get('status'),
                              deadline: snapGoals.data!.docs
                                  .elementAt(i)
                                  .get('deadline'),
                              deadlineBulan: snapGoals.data!.docs
                                  .elementAt(i)
                                  .get('deadline_bulan'),
                              uid: snapGoals.data!.docs.elementAt(i).id,
                              createdAt: snapGoals.data!.docs
                                  .elementAt(i)
                                  .get('created_at')),
                        ),
                      );
                    } else {
                      return InkWell(
                        onTap: () => Navigator.pushNamed(context, '/goals'),
                        child: Container(
                            width: _sizeConfig.screenWidth,
                            height: _sizeConfig.blockVertical! * 10,
                            margin: EdgeInsets.only(
                              top: _sizeConfig.blockVertical! * 4,
                              left: _sizeConfig.marginHorizontalSize!,
                              right: _sizeConfig.marginHorizontalSize!,
                            ),
                            padding: EdgeInsets.symmetric(
                              // vertical: _sizeConfig.marginHorizontalSize!,
                              horizontal: _sizeConfig.marginHorizontalSize!,
                            ),
                            decoration: BoxDecoration(
                              color: mPrimaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                                child: Text(
                              'Ayo segera buat tujuanmu menabung !!!',
                              style: mTitleStyle.copyWith(
                                  color: Colors.white, fontSize: 18),
                            ))),
                      );
                    }
                  } else {
                    return Container();
                  }
                }),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      leading: Container(),
      title: Text(
        'List Goals',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/goals');
          },
          icon: Icon(FontAwesomeIcons.plus),
          tooltip: 'Tambah Goals',
        )
      ],
    );
  }

  Container _goalsLayout(
      {required int index,
      required String title,
      required String target,
      required String status,
      required String deadline,
      required num deadlineBulan,
      required String uid,
      required String createdAt}) {
    deadline = deadline.split('-')[1];
    createdAt = createdAt.split('-')[1];
    var month = int.parse(deadline) - int.parse(createdAt);
    var perbulan = (int.parse(target) / deadlineBulan).toStringAsFixed(0);
    return Container(
        width: _sizeConfig.screenWidth,
        height: _sizeConfig.blockVertical! * 16,
        margin: EdgeInsets.only(
          top: _sizeConfig.blockVertical! * 4,
          left: _sizeConfig.marginHorizontalSize!,
          right: _sizeConfig.marginHorizontalSize!,
        ),
        padding: EdgeInsets.symmetric(
          // vertical: _sizeConfig.marginHorizontalSize!,
          horizontal: _sizeConfig.marginHorizontalSize!,
        ),
        decoration: BoxDecoration(
          color: mPrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _sizeConfig.blockVertical! * 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: mRowTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 4,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  'Rp. ${currencyFormat.format(int.parse(target))}',
                  style: mRowTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 4,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
            SizedBox(
              height: _sizeConfig.blockVertical! * 0.6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                    text: TextSpan(
                        text: status,
                        style: mWarningTextStyle.copyWith(
                          fontSize: _sizeConfig.blockHorizontal! * 3.0,
                          fontWeight: FontWeight.w400,
                        ),
                        children: <TextSpan>[
                      TextSpan(
                        text: ' - $deadlineBulan Bulan',
                        style: mRowTextStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 3.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      )
                    ])),
                Text(
                  'Rp. ${currencyFormat.format(int.parse(perbulan))}/Bulan',
                  style: mRowTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 3.4,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ],
            ),
            TextButton(
                onPressed: () => Navigator.pushNamed(context, '/detail_goals',
                    arguments: GoalsArgument(
                        goalsId: uid,
                        index: index,
                        currentSaldo: _currentSaldo)),
                child: Text('Detail',
                    style: mSubtitleStyle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)))
          ],
        ));
  }
}
