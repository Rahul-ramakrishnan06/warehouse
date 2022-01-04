


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wa/model/city_model.dart';
import 'package:wa/model/product_model.dart';
import 'package:wa/model/user_model.dart';
import 'package:wa/model/ware_model.dart';



final userLogged = StateProvider((ref)=>FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref)=>'');
final forceReload = StateProvider((ref)=>false);

final userInformation = StateProvider((ref)=>UserModel());

//Booking Screen
final currentStep = StateProvider((ref)=>1);
final selectedCity = StateProvider((ref)=>CityModel());
final selectionWarehouse=StateProvider((ref)=>WareModel());
final selectedProduct=StateProvider((ref)=>ProductModel());
final selectedDate=StateProvider((ref)=>DateTime.now());
final selectedTimeSlot=StateProvider((Ref)=>-1);
final selectedTime = StateProvider ((ref)=>'');