

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wa/model/city_model.dart';
import 'package:wa/model/product_model.dart';
import 'package:wa/model/ware_model.dart';

Future<List<CityModel>> getCities()async{
  var cities = new List<CityModel>.empty(growable: true);
  var cityRef = FirebaseFirestore.instance.collection('Allwarehouses');
  var snapshot =await cityRef.get();
  snapshot.docs.forEach((element) {
    cities.add(CityModel.fromJson(element.data()));
  });
  return cities;

}

Future<List<WareModel>> getwareByCity(String cityName)async{
  var ware = new List<WareModel>.empty(growable: true);
  var wareRef = FirebaseFirestore.instance.collection('Allwarehouses').doc(cityName).collection('branch');
  var snapshot =await wareRef.get();
  snapshot.docs.forEach((element) {
    var warepro= WareModel.fromJson(element.data());
    warepro.docId=element.id;
    warepro.reference=element.reference;
    ware.add(warepro);
  });
  return ware;

}

Future<List<ProductModel>> getProductsByWare(WareModel warepro)async{
  var products = new List<ProductModel>.empty(growable: true);
  var productRef = warepro.reference.collection('product');
  var snapshot =await productRef.get();
  snapshot.docs.forEach((element) {
    var product= ProductModel.fromJson(element.data());
    product.docId=element.id;
    product.reference=element.reference;
    products.add(product);
  });
  return products;

}