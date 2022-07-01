import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPengeluaranPage extends StatefulWidget {
  const ListPengeluaranPage({Key? key}) : super(key: key);

  @override
  _ListPengeluaranPageState createState() => _ListPengeluaranPageState();
}

class _ListPengeluaranPageState extends State<ListPengeluaranPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  DateTime now = DateTime.now();

  getPref() async {
    SharedPreferences pref = preferences;
    pref = pref;
    print('user_id : ' + pref.getString('user_id')!);
    print('name : ' + pref.getString('name')!);
    setState(() {
      uid = pref.getString('user_id')!;
    });
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
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
            stream: users
                .doc(uid)
                .collection('pengeluaran')
                .orderBy('created_at', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding:
                      EdgeInsets.only(bottom: _sizeConfig.blockVertical! * 4),
                  child: Column(
                    children: snapshot.data!.docs
                        .map((e) => _card(
                            nominal: e['jumlah'].toString(),
                            kategori: e['kategori'],
                            waktu: e['created_at']))
                        .toList(),
                  ),
                );
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
      title: Text(
        'List Pengeluaran',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
    );
  }

  Icon _categoryIcon(String kategori) {
    if (kategori == 'food') {
      return const Icon(
        Icons.fastfood,
        color: Colors.white,
      );
    }
    if (kategori == 'toilet') {
      return const Icon(
        FontAwesomeIcons.toilet,
        color: Colors.white,
      );
    } else if (kategori == 'kendaraan') {
      return const Icon(
        FontAwesomeIcons.motorcycle,
        color: Colors.white,
      );
    } else if (kategori == 'kesehatan') {
      return const Icon(
        Icons.health_and_safety,
        color: Colors.white,
      );
    } else if (kategori == 'asuransi') {
      return const Icon(
        Icons.monetization_on,
        color: Colors.white,
      );
    } else if (kategori == 'perabotan') {
      return const Icon(
        Icons.weekend,
        color: Colors.white,
      );
    } else if (kategori == 'elektronik') {
      return const Icon(
        Icons.phonelink,
        color: Colors.white,
      );
    } else if (kategori == 'kosmetik') {
      return const Icon(
        Icons.face_retouching_natural,
        color: Colors.white,
      );
    } else if (kategori == 'pakaian') {
      return const Icon(
        Icons.watch,
        color: Colors.white,
      );
    } else {
      return const Icon(
        Icons.control_point_duplicate,
        color: Colors.white,
      );
    }
  }

  Container _card(
      {required String nominal,
      required String kategori,
      required String waktu}) {
    return Container(
      width: _sizeConfig.screenWidth,
      height: _sizeConfig.blockVertical! * 8,
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
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        _categoryIcon(kategori),
        const SizedBox(
          width: 14,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
              text: TextSpan(
                  text: 'Rp. $nominal - $kategori\n',
                  style: mRowTextStyle.copyWith(
                    fontSize: _sizeConfig.blockHorizontal! * 4.4,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  children: [
                const WidgetSpan(
                  child: SizedBox(height: 20),
                ),
                TextSpan(
                  text: waktu,
                  style: mWarningTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 3.4,
                      fontWeight: FontWeight.w400),
                )
              ])),
        ),
      ]),
    );
  }
}
