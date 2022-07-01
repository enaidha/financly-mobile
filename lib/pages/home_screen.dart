import 'package:finance_plan/pages/base_screen.dart';
import 'package:finance_plan/pages/laporan_page.dart';
import 'package:finance_plan/pages/list_goals_page.dart';
import 'package:finance_plan/pages/pemasukan_page.dart';
import 'package:finance_plan/pages/pengeluaran_page.dart';
import 'package:flutter/material.dart';

import '../constants/color_constant.dart';
import '../constants/size_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SizeConfig _sizeConfig = SizeConfig();
  int index = 0;

  final List<Widget> screen = const [
    BaseScreen(),
    ListGoalsPage(),
    LaporanPage(),
    PemasukanPage(),
    PengeluaranPage()
  ];

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);
    return Scaffold(
      body: IndexedStack(
        children: screen,
        index: index,
      ),
      bottomNavigationBar: _myBottomBar(),
      floatingActionButton: _myFloat(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _myBottomBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        // sets the background color of the `BottomNavigationBar`
        canvasColor: mPrimaryColor,
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        primaryColor: Colors.red,
      ),
      child: BottomAppBar(
        color: mPrimaryColor,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: _sizeConfig.blockVertical! * 8,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      index = 1;
                    });
                  },
                  child: Icon(
                    Icons.add_reaction,
                    color: index == 1 ? Colors.amber.shade100 : Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      index = 2;
                    });
                  },
                  splashFactory: NoSplash.splashFactory,
                  child: Icon(
                    Icons.restore_page_rounded,
                    color: index == 2 ? Colors.amber.shade100 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 26,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      index = 3;
                    });
                  },
                  splashFactory: NoSplash.splashFactory,
                  child: Icon(
                    Icons.arrow_circle_down_rounded,
                    color: index == 3 ? Colors.amber.shade100 : Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      index = 4;
                    });
                  },
                  splashFactory: NoSplash.splashFactory,
                  child: Icon(
                    Icons.arrow_circle_up_rounded,
                    color: index == 4 ? Colors.amber.shade100 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton _myFloat() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          index = 0;
        });
      },
      backgroundColor: mYellowColor,
      child: const Icon(Icons.home),
      tooltip: 'Home',
    );
  }
}
