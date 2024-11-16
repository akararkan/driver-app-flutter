import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? phone;
  String? name;
  String? id;
  String? email;
  String? onlineTime;

  UserModel({
    this.name,
    this.phone,
    this.id,
    this.email,
    this.onlineTime
  });


  UserModel.formSnapshot(DataSnapshot snapshot){
    phone = (snapshot.value as dynamic)["phone"];
    email = (snapshot.value as dynamic)["email"];
    name = (snapshot.value as dynamic)["name"];
    id = (snapshot.value as dynamic)["id"];
    onlineTime =( snapshot.value as dynamic)["onlineTime"];
  }


}