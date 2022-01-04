


import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wa/cloud_firestore/banner_ref.dart';
import 'package:wa/cloud_firestore/lookbook_ref.dart';
import 'package:wa/cloud_firestore/user_ref.dart';
import 'package:wa/model/image_model.dart';
import 'package:wa/model/user_model.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return
      SafeArea(child: Scaffold(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              //User Profile
              FutureBuilder(
              future: getUserProfiles(context,FirebaseAuth.instance.currentUser.phoneNumber),
              builder: (context,snapshot){
                if(snapshot.connectionState== ConnectionState.waiting)
                  return Center(child:CircularProgressIndicator(),);
                else{
                  var userModel =snapshot.data as UserModel;
                  return Container(
                    decoration: BoxDecoration(color: Colors.lightGreen),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                          maxRadius: 30,
                          backgroundColor: Colors.red,
                        ),
                        SizedBox(width: 30),
                        Expanded(
                            child: Column(children: [
                          Text('${userModel.name}',style: GoogleFonts.robotoMono(fontSize: 22,color: Colors.white,fontWeight:FontWeight.bold ),),
                          Text('${userModel.address}',overflow: TextOverflow.ellipsis,style: GoogleFonts.robotoMono(fontSize: 18,color: Colors.white,),),

                        ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            )
                        )
                        
                      ],
                    ),
                  );
                }
              }),
              //Menu
              Padding(padding: const EdgeInsets.all(4),child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: GestureDetector(onTap: ()=>Navigator.pushNamed(context,'/booking'),child: Container(child: Card(child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online,size: 58,),
            Text('Booking',style: GoogleFonts.robotoMono(),)
          ],
        ),)),)),),
                  Expanded(child: Container(child: Card(child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart,size: 58,),
                        Text('Cart',style: GoogleFonts.robotoMono(),)
                      ],
                    ),)),)),
                  Expanded(child: Container(child: Card(child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,size: 58,),
                        Text('History',style: GoogleFonts.robotoMono(),)
                      ],
                    ),)),)),
                ],
              ),),
              //Banner
              FutureBuilder(
                  future: getBanners(),
                  builder:(context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator(),);
                    else{
                      var banners =snapshot.data as List<ImageModel>;
                      return CarouselSlider(
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          aspectRatio: 3.0,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3)
                        ),
                        items: banners.map((e) => Container(child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(e.image),
                      ),
                        )
                        ).toList()
                      );
                    }
                  } ),
              //LookBook
              Padding(padding: const EdgeInsets.all(8),child: Row(children: [
                Text('Ware Houses',style: GoogleFonts.robotoMono(fontSize: 24),)
              ],),),
              FutureBuilder(
                  future: getLookbook(),
                  builder:(context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator(),);
                    else{
                      var lookbook =snapshot.data as List<ImageModel>;
                      return Column(children: lookbook.map((e) => Container(padding: const EdgeInsets.all(8),child: ClipRRect(borderRadius: BorderRadius.circular(8),child:
                      Image.network(e.image),),)).toList());
                    }
                  } )
            ],
          ),
        ),
      )
    ));
  }
}
