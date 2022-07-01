import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/models/user_argument.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_indicator/progress_indicator.dart';

import '../main.dart';

class DetailGoalsPage extends StatefulWidget {
  const DetailGoalsPage({Key? key}) : super(key: key);

  @override
  _DetailGoalsPageState createState() => _DetailGoalsPageState();
}

class _DetailGoalsPageState extends State<DetailGoalsPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime now = DateTime.now();
  double _progres = 0.0;
  double _appendProgres = 0.0;
  double _sisaTarget = 0.0;

  getPref() {
    pref = preferences;
    Future.delayed(const Duration(seconds: 0)).then((value) {
      setState(() {
        uid = preferences.getString('user_id')!;
        args = ModalRoute.of(context)!.settings.arguments as GoalsArgument;
      });
    });
  }

  late GoalsArgument args;

  @override
  void initState() {
    getPref();
    super.initState();
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: uid == null
            ? const SizedBox.shrink()
            : FutureBuilder<DocumentSnapshot>(
                future: users
                    .doc(uid!)
                    .collection('goals')
                    .doc(args.goalsId!)
                    .get(),
                builder: (context, snapGoals) {
                  if (snapGoals.hasData) {
                    Map<String, dynamic> data =
                        snapGoals.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: users
                              .doc(uid!)
                              .collection('goals')
                              .doc(snapGoals.data!.id)
                              .snapshots(),
                          builder: (context, snap) {
                            if (snap.hasData) {
                              _appendProgres = 100.0 / data['deadline_bulan'];
                              return StreamBuilder<QuerySnapshot>(
                                  stream: users
                                      .doc(uid!)
                                      .collection('goals')
                                      .doc(args.goalsId!)
                                      .collection('checklistgoals')
                                      .orderBy('deadline_bulanan')
                                      .snapshots(),
                                  builder: (context, snapSisa) {
                                    if (snapSisa.hasData) {
                                      num totalDone = 0;
                                      for (var i = 0;
                                          i < snapSisa.data!.docs.length;
                                          i++) {
                                        if (snapSisa.data!.docs.elementAt(
                                                i)['status_pembayaran'] !=
                                            'done') {
                                          totalDone += snapSisa.data!.docs
                                              .elementAt(
                                                  i)['jumlah_goals_bulanan'];
                                        }
                                      }
                                      return _detailLayout(
                                          goalsId: snapGoals.data!.id,
                                          title: snap.data!.exists
                                              ? snap.data!.get('nama')
                                              : '',
                                          target: data['target'].toString(),
                                          status: data['status'],
                                          deadline: data['deadline'],
                                          createdAt: data['created_at'],
                                          progres: (snap.data!.exists
                                                  ? snap.data!.get('progres')
                                                  : 0) is String
                                              ? int.parse(
                                                  snap.data!.get('progres'))
                                              : (snap.data!.exists
                                                  ? snap.data!.get('progres')
                                                  : 0),
                                          sisaTarget: totalDone);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  });
                            } else {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: users
                              .doc(uid!)
                              .collection('goals')
                              .doc(args.goalsId!)
                              .collection('checklistgoals')
                              .orderBy('deadline_bulanan')
                              .snapshots(),
                          builder: (context, snap) {
                            if (snap.hasData) {
                              int totalDone = 0;
                              for (var i = 0; i < snap.data!.docs.length; i++) {
                                if (snap.data!.docs
                                        .elementAt(i)['status_pembayaran'] ==
                                    'done') {
                                  totalDone++;
                                } else {
                                  _sisaTarget += snap.data!.docs
                                      .elementAt(i)['jumlah_goals_bulanan'];
                                }
                              }
                              _progres =
                                  (100.0 / snap.data!.docs.length) * totalDone;
                              // print('check data : ' +
                              //     snap.data!.docs
                              //         .elementAt(0)['status_pembayaran']
                              //         .toString());
                              if (snap.hasData) {
                                String? st;
                                return Column(
                                  children: snap.data!.docs.map((e) {
                                    var checklist = _checkList(
                                        e['pembayaran'],
                                        e['deadline_bulanan'],
                                        e['jumlah_goals_bulanan'],
                                        e['status_pembayaran'],
                                        args.goalsId!,
                                        e.id,
                                        st);
                                    st = e['status_pembayaran'];
                                    return checklist;
                                  }).toList(),
                                );
                              } else {
                                return Center(
                                    child: Text('Checklist tidak tersedia.',
                                        style: mCardTitleStyle.copyWith(
                                            fontSize:
                                                _sizeConfig.blockHorizontal! *
                                                    4,
                                            fontWeight: FontWeight.w400,
                                            color: mDangerColor)));
                              }
                            } else {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                          },
                        )
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
      ),
      //  StreamBuilder<QuerySnapshot>(
      //     stream: users
      //         .doc(uid)
      //         .collection('goals')
      //         .orderBy('created_at', descending: false)
      //         .snapshots(),
      //     builder: (context, snapGoals) {
      //       if (snapGoals.hasData) {
      //         return Column(
      //           children: snapGoals.data!.docs
      //               .map((e) => _goalsLayout(
      //                   title: e['nama'],
      //                   target: e['target'].toString(),
      //                   status: e['status'],
      //                   deadline: e['deadline'],
      //                   createdAt: e['created_at']))
      //               .toList(),
      //         );
      //       } else {
      //         return Container();
      //       }
      //     }),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      title: Text(
        'Details Goals',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
    );
  }

  Container _checkList(
      String pembayaranKe,
      String deadline,
      num nominal,
      String statusPembayaran,
      String goalsId,
      String id,
      String? statusPembayaranSebelum) {
    bool isValid = statusPembayaranSebelum != null
        ? statusPembayaranSebelum != "undone"
        : true;
    bool isChecked = statusPembayaran == 'undone' ? false : true;
    String nominals = nominal.toStringAsFixed(2);
    return Container(
      width: _sizeConfig.blockHorizontal! * 90,
      height: _sizeConfig.blockVertical! * 10,
      margin: EdgeInsets.symmetric(
          horizontal: _sizeConfig.marginHorizontalSize!, vertical: 10),
      padding: EdgeInsets.all(_sizeConfig.blockHorizontal! * 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: mPrimaryColor),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
                text: '$pembayaranKe\n',
                style: mTitleStyle.copyWith(color: Colors.white, fontSize: 14),
                children: <TextSpan>[
                  TextSpan(
                      text: deadline,
                      style: mTitleStyle.copyWith(
                          color: Colors.white, fontSize: 16))
                ]),
          ),
          const Spacer(),
          Text('Rp. ${currencyFormat.format(num.parse(nominals))}',
              style: mTitleStyle.copyWith(color: Colors.white, fontSize: 16)),
          Checkbox(
            value: isChecked,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            onChanged: statusPembayaran == 'undone'
                ? (bool? value) {
                    if (isValid) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                  "Apakah anda yakin?",
                                  style: mInputStyle.copyWith(
                                      fontSize:
                                          _sizeConfig.blockVertical! * 2.6,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                                actions: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: mPrimaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Text(
                                        "Tidak",
                                        style: mInputStyle.copyWith(
                                            fontSize:
                                                _sizeConfig.blockVertical! * 2,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      int bayarKe =
                                          int.parse(pembayaranKe.split('-')[1]);
                                      save(goalsId, id, bayarKe);
                                      setState(() {
                                        isChecked = true;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: mPrimaryColor,
                                          border:
                                              Border.all(color: mPrimaryColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Text("Yakin",
                                          style: mInputStyle.copyWith(
                                              fontSize:
                                                  _sizeConfig.blockVertical! *
                                                      2,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ));
                    } else {
                      var snackbar = SnackBar(
                        content: Text(
                          'Selesaikan pembayaran sebelumnya',
                          style: mCardTitleStyle.copyWith(
                            fontSize: _sizeConfig.blockHorizontal! * 4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }
                  }
                : null,
          )
        ],
      ),
    );
  }

  Center _detailLayout(
      {required String goalsId,
      required String title,
      required String target,
      required String status,
      required String deadline,
      required String createdAt,
      required num progres,
      required num sisaTarget}) {
    // deadline = deadline.split('-')[1];
    createdAt = createdAt.split('-')[1];
    // var month = int.parse(deadline) - int.parse(createdAt);
    // var perbulan = (int.parse(target) / month).toStringAsFixed(0);

    // print('sisa target : ' + sisaTarget);
    // double sisaTarget = (double.parse(target) * progres.toDouble()) / 100;
    return Center(
      child: Container(
        width: _sizeConfig.blockHorizontal! * 80,
        height: _sizeConfig.blockVertical! * 40,
        margin: EdgeInsets.only(
          top: _sizeConfig.blockVertical! * 4,
          left: _sizeConfig.marginHorizontalSize!,
          right: _sizeConfig.marginHorizontalSize!,
        ),
        padding:
            EdgeInsets.symmetric(horizontal: _sizeConfig.marginHorizontalSize!),
        decoration: BoxDecoration(
          color: mPrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(
              height: _sizeConfig.blockVertical! * 2,
            ),
            Text(
              title,
              style: mTitleStyle.copyWith(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              height: _sizeConfig.blockVertical! * 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target',
                  style: mSubtitleStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp. ${currencyFormat.format(int.parse(target))}',
                  style: mSubtitleStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: _sizeConfig.blockVertical! * 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sisa Target',
                  style: mSubtitleStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp. ${currencyFormat.format(int.parse(sisaTarget.toStringAsFixed(0)))}',
                  style: mSubtitleStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: _sizeConfig.blockVertical! * 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BarProgress(
                percentage: progres.toDouble(),
                backColor: Colors.grey,
                gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 71, 64, 53), Colors.red]),
                showPercentage: true,
                textStyle:
                    mTitleStyle.copyWith(fontSize: 20, color: Colors.white38),
                stroke: 40,
                round: true,
              ),
            ),
            SizedBox(
              height: _sizeConfig.blockVertical! * 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_goals',
                          arguments: GoalsArgument(
                            goalsId: goalsId,
                            title: title,
                            target: num.parse(target),
                            deadline: deadline,
                          ));
                    },
                    icon: const Icon(
                      FontAwesomeIcons.edit,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () async {
                      await users
                          .doc(uid)
                          .collection('goals')
                          .doc(goalsId)
                          .collection('checklistgoals')
                          .get()
                          // ignore: avoid_function_literals_in_foreach_calls
                          .then((value) => value.docs.forEach((element) {
                                users
                                    .doc(uid)
                                    .collection('goals')
                                    .doc(goalsId)
                                    .collection('checklistgoals')
                                    .doc(element.id)
                                    .get()
                                    .then((value) {
                                  int notifId = value.data()!['notif_id'];
                                  users
                                      .doc(uid)
                                      .collection('notif')
                                      .doc(notifId.toString())
                                      .delete();
                                  flutterLocalNotificationsPlugin
                                      .cancel(notifId);
                                  users
                                      .doc(uid)
                                      .collection('goals')
                                      .doc(goalsId)
                                      .collection('checklistgoals')
                                      .doc(element.id)
                                      .delete();
                                });
                              }));
                      await users
                          .doc(uid)
                          .collection('goals')
                          .doc(goalsId)
                          .delete();

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
                    },
                    icon: const Icon(
                      FontAwesomeIcons.trashAlt,
                      color: Colors.white,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  save(String goalsId, String doc, int bayarKe) {
    users
        .doc(uid!)
        .collection('goals')
        .doc(goalsId)
        .collection('checklistgoals')
        .doc(doc)
        .update({'status_pembayaran': "done"}).then((response) {
      if ((_appendProgres * bayarKe) >= 100) {
        users
            .doc(uid!)
            .collection('goals')
            .doc(goalsId)
            .update({'status': 'done', 'progres': _appendProgres * bayarKe});
      } else {
        users
            .doc(uid!)
            .collection('goals')
            .doc(goalsId)
            .update({'progres': _appendProgres * bayarKe});
      }
    });
  }
}
