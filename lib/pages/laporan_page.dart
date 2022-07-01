import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/constants.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  int _filterBulan = 0;
  List<String> bulanToString = const [
    "00",
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12"
  ];
  int _filterTahun = 0;
  String _selectedBulan = "0";
  String _selectedTahun = "0";
  String _filterLaporan = 'Semua';
  bool _filterPemasukan = true;
  bool _sort = true;
  final _arrYear = [2022, 2023, 2024, 2025];
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

  List<DropdownMenuItem<String>> get _dropdownYearItem {
    List<DropdownMenuItem<String>> menuItems = const [
      DropdownMenuItem(child: Text("Pilih Tahun"), value: "0"),
      DropdownMenuItem(child: Text("2022"), value: "2022"),
      DropdownMenuItem(child: Text("2023"), value: "2023"),
      DropdownMenuItem(child: Text("2024"), value: "2024"),
      DropdownMenuItem(child: Text("2025"), value: "2025"),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get _dropdownMonthItem {
    List<DropdownMenuItem<String>> menuItems = const [
      DropdownMenuItem(child: Text("Pilih Bulan"), value: "0"),
      DropdownMenuItem(child: Text("Januari"), value: "1"),
      DropdownMenuItem(child: Text("Februari"), value: "2"),
      DropdownMenuItem(child: Text("Maret"), value: "3"),
      DropdownMenuItem(child: Text("April"), value: "4"),
      DropdownMenuItem(child: Text("Mei"), value: "5"),
      DropdownMenuItem(child: Text("Juni"), value: "6"),
      DropdownMenuItem(child: Text("Juli"), value: "7"),
      DropdownMenuItem(child: Text("Agustus"), value: "8"),
      DropdownMenuItem(child: Text("September"), value: "9"),
      DropdownMenuItem(child: Text("Oktober"), value: "10"),
      DropdownMenuItem(child: Text("November"), value: "11"),
      DropdownMenuItem(child: Text("Desember"), value: "12"),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(
                  //     onPressed: () {
                  //       _filterYear();
                  //     },
                  //     icon: const Icon(Icons.format_list_numbered)),
                  IconButton(
                      onPressed: () {
                        //_filterYearMonth();
                        _datePicker(context: context);
                      },
                      icon: const Icon(Icons.format_align_justify)),
                  InkWell(
                    onTap: () {
                      _filter();
                    },
                    child: Container(
                      width: _sizeConfig.blockHorizontal! * 50,
                      color: mPrimaryColor,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _filterLaporan,
                            style: mTitleStyle.copyWith(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _sort = !_sort;
                        });
                      },
                      icon: const Icon(Icons.format_line_spacing)),
                ],
              ),
            ),
            uid == null || uid!.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _filterTahun > 0 &&
                            _filterBulan == 0 &&
                            _filterLaporan.contains('Semua')
                        ? users
                            .doc(uid!)
                            .collection('laporan')
                            .where('year_created',
                                isEqualTo: _filterTahun.toString())
                            .orderBy('nominal', descending: _sort)
                            .snapshots()
                        : _filterTahun > 0 &&
                                _filterBulan > 0 &&
                                _filterLaporan.contains('Semua')
                            ? users
                                .doc(uid!)
                                .collection('laporan')
                                .where('year_created',
                                    isEqualTo: _filterTahun.toString())
                                .where('month_created',
                                    isEqualTo: bulanToString[_filterBulan])
                                .orderBy('nominal', descending: _sort)
                                .snapshots()
                            : _filterTahun == 0 &&
                                    _filterBulan > 0 &&
                                    _filterLaporan.contains('Semua')
                                ? users
                                    .doc(uid!)
                                    .collection('laporan')
                                    .where('month_created',
                                        isEqualTo: bulanToString[_filterBulan])
                                    .orderBy('nominal', descending: _sort)
                                    .snapshots()
                                : _filterTahun == 0 &&
                                        _filterBulan == 0 &&
                                        !_filterLaporan.contains('Semua')
                                    ? users
                                        .doc(uid!)
                                        .collection('laporan')
                                        .where('is_pemasukan',
                                            isEqualTo: _filterPemasukan)
                                        .orderBy('nominal', descending: _sort)
                                        .snapshots()
                                    : _filterTahun > 0 &&
                                            _filterBulan == 0 &&
                                            !_filterLaporan.contains('Semua')
                                        ? users
                                            .doc(uid!)
                                            .collection('laporan')
                                            .where('year_created',
                                                isEqualTo:
                                                    _filterTahun.toString())
                                            .where('is_pemasukan',
                                                isEqualTo: _filterPemasukan)
                                            .orderBy('nominal',
                                                descending: _sort)
                                            .snapshots()
                                        : _filterTahun > 0 &&
                                                _filterBulan > 0 &&
                                                !_filterLaporan
                                                    .contains('Semua')
                                            ? users
                                                .doc(uid!)
                                                .collection('laporan')
                                                .where('year_created',
                                                    isEqualTo:
                                                        _filterTahun.toString())
                                                .where('month_created',
                                                    isEqualTo: bulanToString[
                                                        _filterBulan])
                                                .where('is_pemasukan',
                                                    isEqualTo: _filterPemasukan)
                                                .orderBy('nominal',
                                                    descending: _sort)
                                                .snapshots()
                                            : _filterTahun == 0 &&
                                                    _filterBulan > 0 &&
                                                    !_filterLaporan
                                                        .contains('Semua')
                                                ? users
                                                    .doc(uid!)
                                                    .collection('laporan')
                                                    .where('month_created',
                                                        isEqualTo:
                                                            bulanToString[
                                                                _filterBulan])
                                                    .where('is_pemasukan',
                                                        isEqualTo:
                                                            _filterPemasukan)
                                                    .orderBy('nominal',
                                                        descending: _sort)
                                                    .snapshots()
                                                : users
                                                    .doc(uid!)
                                                    .collection('laporan')
                                                    .orderBy('nominal',
                                                        descending: _sort)
                                                    .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.size > 0) {
                        if (_filterLaporan.contains('Semua')) {
                          var date = DateTime.now();
                          String now = date.toString().split('.')[0];

                          num totalPemasukan = 0;
                          num totalPengeluaran = 0;

                          for (var i = 0; i < snapshot.data!.size; i++) {
                            if (snapshot.data!.docs[i].get('is_pemasukan')) {
                              totalPemasukan +=
                                  snapshot.data!.docs[i].get('nominal');
                            } else {
                              totalPengeluaran +=
                                  snapshot.data!.docs[i].get('nominal');
                            }
                          }

                          return Column(
                            children: [
                              _card(
                                  nominal: totalPemasukan.toString(),
                                  judul: "Total Pemasukan",
                                  isPemasukan: true,
                                  waktu: now),
                              _card(
                                  nominal: totalPengeluaran.toString(),
                                  judul: "Total Pengeluaran",
                                  isPemasukan: false,
                                  waktu: now),
                            ],
                          );
                        } else {
                          return Column(
                            children: snapshot.data!.docs
                                .map((e) => _card(
                                    nominal: e['nominal'].toString(),
                                    judul: e['judul'],
                                    isPemasukan: e['is_pemasukan'],
                                    waktu: e['created_at']))
                                .toList(),
                          );
                        }
                      } else {
                        return Center(
                          child: Text(
                            'Data tidak ada.',
                            style: mRowTextStyle,
                          ),
                        );
                      }
                    })
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      leading: Container(),
      title: Text(
        'Rekap Bulanan',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
    );
  }

  Container _card(
      {required String nominal,
      required String judul,
      required String waktu,
      required bool isPemasukan}) {
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
        Icon(
          Icons.label,
          color: isPemasukan == true ? Colors.greenAccent : Colors.red,
        ),
        const SizedBox(
          width: 14,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
              text: TextSpan(
                  text: 'Rp. ${currencyFormat.format(int.parse(nominal))}\n',
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
                  text: judul.toLowerCase(),
                  style: mWarningTextStyle.copyWith(
                      fontSize: _sizeConfig.blockHorizontal! * 3.4,
                      fontWeight: FontWeight.w400),
                )
              ])),
        ),
      ]),
    );
  }

  _filter() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: _sizeConfig.blockHorizontal! * 70,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    print('Semua');
                    setState(() {
                      _filterLaporan = 'Semua';
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterLaporan == 'Semua' ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Semua',
                      style: mTitleStyle.copyWith(
                        color: _filterLaporan == 'Semua'
                            ? mPrimaryColor
                            : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Pemasukan');
                    setState(() {
                      _filterLaporan = 'Pemasukan';
                      _filterPemasukan = true;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterLaporan == 'Pemasukan' ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Pemasukan',
                      style: mTitleStyle.copyWith(
                        color: _filterLaporan == 'Pemasukan'
                            ? mPrimaryColor
                            : Colors.black,
                        fontSize: 14,
                      )),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  onTap: () {
                    print('Pengeluaran');
                    setState(() {
                      _filterLaporan = 'Pengeluaran';
                      _filterPemasukan = false;
                    });
                    Navigator.pop(context);
                  },
                  selected: _filterLaporan == 'Pengeluaran' ? true : false,
                  selectedColor: mPrimaryColor,
                  title: Text('Pengeluaran',
                      style: mTitleStyle.copyWith(
                        color: _filterLaporan == 'Pengeluaran'
                            ? mPrimaryColor
                            : Colors.black,
                        fontSize: 14,
                      )),
                ),
              ],
            ),
          );
        });
  }

  Stream<QuerySnapshot<Object?>>? getStream() {}

  _filterYearMonth() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return SizedBox(
              height: _sizeConfig.blockHorizontal! * 70,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(children: [
                  DropdownButton(
                      items: _dropdownYearItem,
                      value: _selectedTahun,
                      onChanged: (String? value) {
                        print('selected year : $value');
                        this.setState(() {
                          setState(() {
                            _selectedTahun = value!;
                            _filterTahun = int.parse(value);
                          });
                        });
                      }),
                  DropdownButton(
                      items: _dropdownMonthItem,
                      value: _selectedBulan,
                      onChanged: (String? value) {
                        print('selected month : $value');
                        this.setState(() {
                          setState(() {
                            _selectedBulan = value!;
                            _filterBulan = int.parse(value);
                          });
                        });
                      }),
                  const SizedBox(
                    height: 12,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: mPrimaryColor,
                      ),
                      child: Text('Filter',
                          style: mInputStyle.copyWith(
                              fontSize: _sizeConfig.blockVertical! * 2.6,
                              fontWeight: FontWeight.w400,
                              color: Colors.white)))
                ]),
              ),
            );
          });
        });
  }

  Future<void> _datePicker({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
        context: context,
        initialDate: DateTime(
            _filterTahun > 0 ? _filterTahun : DateTime.now().year,
            _filterBulan > 0 ? _filterBulan : DateTime.now().month),
        firstDate: DateTime(2022),
        lastDate: DateTime(2030),
        locale: localeObj,
        builder: (context, widget) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget ?? const SizedBox.shrink(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _filterBulan = 0;
                        _filterTahun = 0;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Text("Hapus Filter")),
                  )
                ],
              ),
            ),
          );
        });

    if (selected != null) {
      setState(() {
        //_selectedDate = selected;
        _filterBulan = selected.month;
        _filterTahun = selected.year;
      });
    }
  }
}
