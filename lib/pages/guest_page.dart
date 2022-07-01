import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:flutter/material.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({Key? key}) : super(key: key);

  @override
  _GuestPageState createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  final SizeConfig _sizeConfig = SizeConfig();

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: _sizeConfig.screenWidth,
          height: _sizeConfig.screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: _sizeConfig.blockHorizontal! * 60,
                height: _sizeConfig.blockHorizontal! * 60,
                child: Image.asset(
                  'assets/images/logo.png',
                ),
              ),
              const Spacer(),
              Container(
                width: _sizeConfig.screenWidth,
                padding: EdgeInsets.symmetric(
                    horizontal: _sizeConfig.blockHorizontal! * 3,
                    vertical: _sizeConfig.blockHorizontal! * 4),
                    child: Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: _sizeConfig.screenWidth,
                          height: _sizeConfig.blockHorizontal! * 14,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2, color: mBorderColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'LOG IN',
                              style: mInputStyle.copyWith(
                                  fontSize: _sizeConfig.btnTextSize,
                                  fontWeight: FontWeight.w600,
                                  color: mBorderColor),
                            ),
                          ),
                        )),
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Flexible(
                //         flex: 1,
                //         child: SizedBox(
                //           width: _sizeConfig.blockHorizontal! * 50,
                //           height: _sizeConfig.blockHorizontal! * 14,
                //           child: ElevatedButton(
                //             onPressed: () {
                //               Navigator.pushNamed(context, '/login');
                //             },
                //             style: ElevatedButton.styleFrom(
                //               primary: Colors.white,
                //               elevation: 0.0,
                //               shape: RoundedRectangleBorder(
                //                 side: const BorderSide(
                //                     width: 2, color: mBorderColor),
                //                 borderRadius: BorderRadius.circular(6),
                //               ),
                //             ),
                //             child: Text(
                //               'LOG IN',
                //               style: mInputStyle.copyWith(
                //                   fontSize: _sizeConfig.btnTextSize,
                //                   fontWeight: FontWeight.w600,
                //                   color: mBorderColor),
                //             ),
                //           ),
                //         )),
                //     SizedBox(
                //       width: _sizeConfig.blockHorizontal! * 2,
                //     ),
                //     Flexible(
                //         flex: 1,
                //         child: SizedBox(
                //           width: _sizeConfig.blockHorizontal! * 50,
                //           height: _sizeConfig.blockHorizontal! * 14,
                //           child: ElevatedButton(
                //             onPressed: () {
                //               Navigator.pushNamed(context, '/register');
                //             },
                //             style: ElevatedButton.styleFrom(
                //               primary: mPrimaryColor,
                //               elevation: 0.0,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(6),
                //               ),
                //             ),
                //             child: Text(
                //               'REGISTER',
                //               style: mInputStyle.copyWith(
                //                   fontSize: _sizeConfig.btnTextSize,
                //                   fontWeight: FontWeight.w600,
                //                   color: Colors.white),
                //             ),
                //           ),
                //         )),
                //   ],
                // ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
