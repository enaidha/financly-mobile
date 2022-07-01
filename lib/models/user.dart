class UserModel {
  String? name;
  String? email;
  String? username;

  UserModel({this.name, this.email, this.username});

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'username': username,
      };
}
