import 'package:sqlite/Helper/Constance.dart';

class UserModel {
  int? id;
  String? name, email, phone;

  UserModel({this.id, this.name, this.email, this.phone});

  toJson() {
    return {
      columnName: name,
      columnPhone: phone,
      columnEmail: email,
    };
  }

  UserModel.fromJson(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    phone = map[columnPhone];
    email = map[columnEmail];
  }
}
