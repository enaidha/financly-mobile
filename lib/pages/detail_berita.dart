import 'package:flutter/material.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailBerita extends StatelessWidget {
  final SizeConfig _sizeConfig = SizeConfig();
  final link, title, pubDate, description, thumbnail;
  DetailBerita(
      {Key? key,
      this.link,
      this.title,
      this.pubDate,
      this.description,
      this.thumbnail})
      : super(key: key);

  void _openWeb() async {
    if (!await launch(link)) throw 'Could not launch $link';
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);
    var dat = pubDate.toString();
    var datee = dat.split('.')[0];
    var tanggal = datee.split(' ')[0];
    var jam = datee.split(' ')[1];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mPrimaryColor,
        title: Text(
          'Detail Berita',
          style: mCardTitleStyle,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: _sizeConfig.blockVertical! * 2,
                left: _sizeConfig.blockHorizontal! * 2),
            child: Text(
              '$title',
              style: mTitleStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(
                    top: _sizeConfig.blockVertical! * 2,
                    bottom: _sizeConfig.blockVertical! * 2,
                    left: _sizeConfig.blockHorizontal! * 2),
                child: RichText(
                  text: TextSpan(
                    text: 'Tanggal : $tanggal',
                    style: mTitleStyle.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                    children: <TextSpan>[
                      TextSpan(
                          text: '  $jam',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' WIB'),
                    ],
                  ),
                )
                // Text(
                //   '$datee',
                //   style: mTitleStyle.copyWith(
                //       fontWeight: FontWeight.bold, color: Colors.grey),
                // ),
                ),
          ),
          SizedBox(
            height: _sizeConfig.blockVertical! * 30,
            width: _sizeConfig.blockHorizontal! * 98,
            child: Image.network(
              thumbnail.toString(),
              fit: BoxFit.cover,
            ),
          ),
          InkWell(
            onTap: _openWeb,
            child: Padding(
              padding: EdgeInsets.only(
                  top: _sizeConfig.blockVertical! * 1,
                  bottom: _sizeConfig.blockVertical! * 2,
                  left: _sizeConfig.blockHorizontal! * 2),
              child: Text(
                '$link',
                style: mTitleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: _sizeConfig.blockVertical! * 1,
                bottom: _sizeConfig.blockVertical! * 2,
                left: _sizeConfig.blockHorizontal! * 2),
            child: Text(
              '$description',
              textDirection: TextDirection.ltr,
              style: mTitleStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
