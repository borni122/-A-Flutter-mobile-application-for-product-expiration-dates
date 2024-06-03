class UserModel {
  late String userId, email, name, pic;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.pic,
  });

  UserModel.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) {
      return;
    }
    userId = map['userId'];
    email = map['email'];
    name = map['name'];
    pic = map['pic'];
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'pic': pic,
    };
  }

  void update({String? email, String? name, String? pic}) {
    if (email != null) this.email = email;
    if (name != null) this.name = name;
    if (pic != null) this.pic = pic;
  }
}
