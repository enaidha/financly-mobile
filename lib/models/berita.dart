import 'dart:convert';

Berita beritaFromJson(String str) => Berita.fromJson(json.decode(str));

String beritaToJson(Berita data) => json.encode(data.toJson());

class Berita {
  Berita({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  dynamic message;
  Data? data;

  factory Berita.fromJson(Map<String, dynamic> json) => Berita(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data!.toJson(),
      };

  map(Null Function() param0) {}
}

class Data {
  Data({
    this.link,
    this.image,
    this.description,
    this.title,
    this.posts,
  });

  String? link;
  String? image;
  String? description;
  String? title;
  List<Post>? posts;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        link: json["link"],
        image: json["image"],
        description: json["description"],
        title: json["title"],
        posts: List<Post>.from(json["posts"].map((x) => Post.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "link": link,
        "image": image,
        "description": description,
        "title": title,
        "posts": List<dynamic>.from(posts!.map((x) => x.toJson())),
      };
}

class Post {
  Post({
    this.link,
    this.title,
    this.pubDate,
    this.description,
    this.thumbnail,
  });

  String? link;
  String? title;
  DateTime? pubDate;
  String? description;
  String? thumbnail;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        link: json["link"],
        title: json["title"],
        pubDate: DateTime.parse(json["pubDate"]),
        description: json["description"],
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "link": link,
        "title": title,
        "pubDate": pubDate!.toIso8601String(),
        "description": description,
        "thumbnail": thumbnail,
      };
}
