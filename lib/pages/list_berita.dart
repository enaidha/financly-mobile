import 'package:finance_plan/pages/detail_berita_webview.dart';
import 'package:flutter/material.dart';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/size_config.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:finance_plan/models/berita.dart';
import '../Network/api.dart';
import 'detail_berita.dart';

class ListBerita extends StatefulWidget {
  ListBerita({Key? key}) : super(key: key);

  @override
  State<ListBerita> createState() => _ListBeritaState();
}

class _ListBeritaState extends State<ListBerita> {
  final SizeConfig _sizeConfig = SizeConfig();

  Berita? berita;
  int? length;
  String? title;

  _initBerita() {
    Network.getBerita().then((response) {
      setState(() {
        berita = response;
        length = berita!.data!.posts!.length;
        var tit = berita!.data!.title.toString();
        title = tit.split('-')[0];
        // print(mitigasi);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initBerita();
  }

  @override
  Widget build(BuildContext context) {
    _sizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mPrimaryColor,
        title: Text(
          'List Berita',
          style: mCardTitleStyle,
        ),
      ),
      body: berita != null
          ? ListView.builder(
              itemCount: length,
              itemBuilder: (context, index) {
                var dat = berita!.data!.posts![index].pubDate.toString();
                var date = dat.split('.')[0];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBeritaWebview(
                                link: berita!.data!.posts![index].link),
                          ));
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DetailBerita(
                      //               link: berita!.data!.posts![index].link,
                      //               title: berita!.data!.posts![index].title,
                      //               pubDate:
                      //                   berita!.data!.posts![index].pubDate,
                      //               description:
                      //                   berita!.data!.posts![index].description,
                      //               thumbnail:
                      //                   berita!.data!.posts![index].thumbnail,
                      //             )));
                    },
                    child: Card(
                        child: SizedBox(
                      height: _sizeConfig.blockVertical! * 15,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _sizeConfig.blockHorizontal! * 30,
                            height: _sizeConfig.blockVertical! * 28,
                            child: Image.network(
                              berita!.data!.posts![index].thumbnail.toString(),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(
                            width: _sizeConfig.blockHorizontal! * 2,
                          ),
                          SizedBox(
                            width: _sizeConfig.blockHorizontal! * 60,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: _sizeConfig.blockVertical! * 1,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(title.toString(),
                                      style: mSubtitleStyle.copyWith(
                                          color: mPrimaryColor)),
                                ),
                                SizedBox(
                                  height: _sizeConfig.blockVertical! * 1,
                                ),
                                Text(
                                    berita!.data!.posts![index].title
                                        .toString(),
                                    style: mSubtitleStyle.copyWith(
                                        color: Colors.black)),
                                SizedBox(
                                  height: _sizeConfig.blockVertical! * 1,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(date.toString(),
                                      style: mSubtitleStyle.copyWith(
                                          color: Colors.grey, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                );
              })
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
