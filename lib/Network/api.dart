import 'package:finance_plan/models/berita.dart';
import 'package:http/http.dart' as http;

class Network {
  static const _DOMAIN = 'api-berita-indonesia.vercel.app';

  static Future<Berita> getBerita() async {
    try {
      var url = Uri.https(_DOMAIN, '/antara/ekonomi');

      var response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final Berita data = beritaFromJson(response.body);
        return data;
      } else {
        return Berita();
      }
    } catch (e) {
      throw Exception('error : ' + e.toString());
    }
  }
}
