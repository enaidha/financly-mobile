import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;
  double? blockHorizontal;
  double? blockVertical;
  double? textTitleSize;
  double? marginHorizontalSize;
  double? btnTextSize;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData?.size.width;
    screenHeight = _mediaQueryData?.size.height;
    blockHorizontal = screenWidth! / 100;
    blockVertical = screenHeight! / 100;
    textTitleSize = blockHorizontal! * 7;
    marginHorizontalSize = blockHorizontal! * 6;
    btnTextSize = blockVertical! * 1.8;
  }
}
