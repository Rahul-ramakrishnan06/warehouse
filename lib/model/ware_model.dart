import 'package:cloud_firestore/cloud_firestore.dart';

class WareModel{
  String name,address,docId;
  DocumentReference reference;


  WareModel({this.name,this.address});

  WareModel.fromJson(Map<String,dynamic> json){
    address =json['address'];
    name=json['name'];
  }

  Map<String,dynamic> tojson(){
    final Map<String,dynamic> data=new Map<String,dynamic>();
    data['address'] =this.address;
    data['name']=this.name;
    return data;
  }


}