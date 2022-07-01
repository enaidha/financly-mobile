import 'package:finance_plan/constants/size_config.dart';
import 'package:flutter/material.dart';

class HeaderStart extends StatelessWidget {
  HeaderStart({ Key? key }) : super(key: key);
  final SizeConfig _sizeConfig = SizeConfig();  

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _sizeConfig.blockHorizontal! * 20,
      ),
      child: Image.asset(
            'assets/images/illustration1.png',
            width: 50,
            height: 70,
          ),
    );
  }
}