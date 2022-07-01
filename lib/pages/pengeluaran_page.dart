import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({Key? key}) : super(key: key);

  @override
  _PengeluaranPageState createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final SizeConfig _sizeConfig = SizeConfig();
  SharedPreferences? pref;
  String? uid = '';
  final _form = GlobalKey<FormState>();
  final TextEditingController _editNominalController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  getPref() async {
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
      var validKategori = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: _sizeConfig.blockVertical! * 50),
        duration: const Duration(seconds: 1),
        content: Text("Belum memilih kategori", style: mDangerTextStyle),
        backgroundColor: Colors.amber,
      );

      if (_selectedValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(validKategori);
        Navigator.pop(context);

        return;
      } else {
        var date = DateTime.now();
        String now = date.toString().split('.')[0];
        String month = now.split('-')[1];
        String year = now.split('-')[0];

        num currentSaldo = 0;
        num totalPengeluaran = 0;
        await users
            .doc(uid)
            .get()
            .then((value) => currentSaldo = value.get('current_saldo'));

        print('c : $currentSaldo');
        CollectionReference pengeluaran =
            users.doc(uid).collection('pengeluaran');
        await pengeluaran.get().then((value) {
          for (var i = 0; i < value.size; i++) {
            setState(() {
              totalPengeluaran += value.docs.elementAt(i).get('jumlah');
            });
          }
        });
        print('current pengeluaran : $totalPengeluaran');
        await pengeluaran.add({
          'kategori': _selectedValue,
          'jumlah': int.parse(_editNominalController.text),
          'hanya_catat': false,
          'created_at': now
        }).whenComplete(() {
          print('nice');
          users.doc(uid).set({
            'current_saldo':
                currentSaldo - int.parse(_editNominalController.text)
          }).whenComplete(() {
            print('done');
          });
        }).catchError((e) {
          print('error : $e');
        });

        /* Adding laporan */
        CollectionReference laporan = users.doc(uid).collection('laporan');

        await laporan.add({
          'judul': _selectedValue,
          'is_pemasukan': false,
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
          backgroundColor: mCardTitleColor,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackbar);

        Navigator.pop(context);
      }
    }else{
      
        Navigator.pop(context);
    }
  }

  pencatatan() async {
    if (_form.currentState!.validate()) {
      var validKategori = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: _sizeConfig.blockVertical! * 50),
        duration: const Duration(seconds: 1),
        content: Text("Belum memilih kategori", style: mDangerTextStyle),
        backgroundColor: Colors.amber,
      );

      if (_selectedValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(validKategori);

        return;
      } else {
        var date = DateTime.now();
        String now = date.toString().split('.')[0];
        String month = now.split('-')[1];
        String year = now.split('-')[0];

        CollectionReference pengeluaran =
            users.doc(uid).collection('pengeluaran');

        await pengeluaran.add({
          'kategori': _selectedValue,
          'jumlah': int.parse(_editNominalController.text),
          'hanya_catat': true,
          'created_at': now
        }).whenComplete(() async {
          print('nice');
          CollectionReference laporan = users.doc(uid).collection('laporan');

          await laporan.add({
            'judul': _selectedValue,
            'is_pemasukan': false,
            'nominal': num.parse(_editNominalController.text),
            'created_at': now,
            'month_created': month,
            'year_created': year,
          });
        }).catchError((e) {
          print('error : $e');
        });

        _editNominalController.clear();

        var snackbar = SnackBar(
          content: Text(
            'Berhasil',
            style: mCardTitleStyle.copyWith(
              fontSize: _sizeConfig.blockHorizontal! * 4,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: mCardTitleColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }else{
        Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  String? _selectedValue;
  bool _onColor = false;

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      appBar: _appBar(),
      body: Form(
        key: _form,
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: Text(
                'Kategori',
                style: mTitleStyle.copyWith(fontSize: 20),
              ),
            ),
            SizedBox(
                height: _sizeConfig.blockVertical! * 60,
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Makan & Minum',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "food"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "food";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.toilet,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Toiletries',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "toilet"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "toilet";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.motorcycle,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Kendaraan',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "kendaraan"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "kendaraan";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.health_and_safety,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Kesehatan',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "kesehatan"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "kesehatan";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Asuransi',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "asuransi"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "asuransi";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.weekend,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Perabotan',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "perabotan"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "perabotan";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phonelink,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Elektronik',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "elektronik"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "elektronik";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.face_retouching_natural,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Kosmetik',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "kosmetik"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "kosmetik";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.watch,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Pakaian',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "pakaian"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "pakaian";
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.control_point_duplicate,
                              size: 50,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Dan Lain-lain',
                                style: mColumnTextStyle.copyWith(fontSize: 11),
                              ),
                            )
                          ],
                        ),
                        color: _selectedValue != "dll"
                            ? Colors.teal[100]
                            : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = "dll";
                        });
                      },
                    ),
                  ],
                )),
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
                  showLogoutDialog(context);
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
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  showLogoutDialog(BuildContext context) {
    // Widget cancelButton = FlatButton(
    //   child: Text("Tidak"),
    //   onPressed: () {
    //     Navigator.pop(context);
    //   },
    // );
    // Widget continueButton = FlatButton(
    //   child: Text("Ya"),
    //   onPressed: () {
    //     print('ya');
    //   },
    // );

    SimpleDialog alert = SimpleDialog(
      title: const Text("Silahkan Pilih"),
      contentPadding: const EdgeInsets.only(left: 10, bottom: 20),
      children: [
        ListTile(
          leading: const Icon(Icons.attach_money),
          minLeadingWidth: 20,
          title: const Text('Dikurangi Saldo'),
          onTap: () {
            submit();
          },
        ),
        ListTile(
          leading: const Icon(Icons.book),
          minLeadingWidth: 20,
          title: const Text('Masuk di Pencatatan Saja'),
          onTap: () {
            pencatatan();
          },
        ),
      ],
      // actions: [
      //   cancelButton,
      //   continueButton,
      // ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: mPrimaryColor,
      title: Text(
        'Pengeluaran',
        style: mCardTitleStyle.copyWith(
          fontSize: _sizeConfig.blockHorizontal! * 6,
        ),
      ),
    );
  }
}
