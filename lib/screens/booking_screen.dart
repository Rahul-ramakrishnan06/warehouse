import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:wa/cloud_firestore/all_warehouse_ref.dart';
import 'package:wa/model/city_model.dart';
import 'package:wa/model/product_model.dart';
import 'package:wa/model/ware_model.dart';
import 'package:wa/state/state_management.dart';
import 'package:wa/utils/utils.dart';

class BookingScreen extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var wareWatch = watch(selectionWarehouse).state;
    var ProductWatch = watch(selectedProduct).state;
    var dateWatch = watch(selectedDate).state;
    var timeWatch = watch(selectedTime).state;
    var timeSlotWatch = watch(selectedTimeSlot).state;

    var test = context.read(selectedCity).state;
    print(test);
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          //step
          NumberStepper(
            activeStep: step - 1,
            direction: Axis.horizontal,
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            numbers: [1, 2, 3, 4, 5],
            stepColor: Colors.black,
            activeStepBorderColor: Colors.black,
            activeStepColor: Colors.red,
            numberStyle: TextStyle(color: Colors.white),
          ),
          //screen
          Expanded(
            flex: 10,
            child: step == 1
                ? displayCityList()
                : step == 2
                    ? displayWare(cityWatch.name)
                    : step == 3
                        ? displayProduct(wareWatch)
                        : step == 4
                            ? displayTimeSlot(context, ProductWatch)
                            : step == 5
                                ? displayConfirm(context)
                                : Container(),
          ),
          //Button
          Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: step == 1
                              ? null
                              : () => context.read(currentStep).state--,
                          child: Text('Previous'),
                        )),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: (step == 1 &&
                                      context.read(selectedCity).state.name ==
                                          null) ||
                                  (step == 2 &&
                                      context
                                              .read(selectionWarehouse)
                                              .state
                                              .docId ==
                                          null) ||
                                  (step == 3 &&
                                      context
                                              .read(selectedProduct)
                                              .state
                                              .docId ==
                                          null) ||
                                  (step == 4 &&
                                      context.read(selectedTimeSlot).state ==
                                          -1)
                              ? null
                              : step == 5
                                  ? null
                                  : () => context.read(currentStep).state++,
                          child: Text('Next'),
                        )),
                      ],
                    ),
                  )))
        ],
      ),
    ));
  }

  displayCityList() {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var cities = snapshot.data as List<CityModel>;
            if (cities == null || cities.length == 0)
              return Center(
                child: Text('Cannot Load the Cities'),
              );
            else
              return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          context.read(selectedCity).state = cities[index],
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.home_work,
                            color: Colors.red,
                          ),
                          trailing: context.read(selectedCity).state.name ==
                                  cities[index].name
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                            '${cities[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                        ),
                      ),
                    );
                  });
          }
        });
  }

  displayWare(String cityName) {
    return FutureBuilder(
        future: getwareByCity(cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var ware = snapshot.data as List<WareModel>;
            if (ware == null || ware.length == 0)
              return Center(
                child: Text('Cannot Load the ware houses'),
              );
            else
              return ListView.builder(
                  itemCount: ware.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          context.read(selectionWarehouse).state = ware[index],
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.home_outlined,
                            color: Colors.red,
                          ),
                          trailing:
                              context.read(selectionWarehouse).state.docId ==
                                      ware[index].docId
                                  ? Icon(Icons.check)
                                  : null,
                          title: Text(
                            '${ware[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                          subtitle: Text(
                            '${ware[index].address}',
                            style: GoogleFonts.robotoMono(
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    );
                  });
          }
        });
  }

  displayProduct(WareModel wareModel) {
    return FutureBuilder(
        future: getProductsByWare(wareModel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var products = snapshot.data as List<ProductModel>;
            if (products == null || products.length == 0)
              return Center(
                child: Text('product list is empty'),
              );
            else
              return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          context.read(selectedProduct).state = products[index],
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.rice_bowl,
                            color: Colors.red,
                          ),
                          trailing: context.read(selectedProduct).state.docId ==
                                  products[index].docId
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                            '${products[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                          subtitle: RatingBar.builder(
                            itemSize: 16,
                            allowHalfRating: true,
                            initialRating: products[index].rating,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            onRatingUpdate: (value) {},
                            itemBuilder: (context, _) =>
                                Icon(Icons.star, color: Colors.amber),
                            itemPadding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    );
                  });
          }
        });
  }

  displayTimeSlot(BuildContext context, ProductModel productModel) {
    var now = context.read(selectedDate).state;
    return Column(
      children: [
        Container(
            color: Color(0xFFFFAB40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          '${DateFormat.MMMM().format(now)}',
                          style: GoogleFonts.robotoMono(color: Colors.white),
                        ),
                        Text(
                          '${now.day}',
                          style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        Text(
                          '${DateFormat.EEEE().format(now)}',
                          style: GoogleFonts.robotoMono(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: now,
                        maxTime: now.add(Duration(days: 31)),
                        onConfirm: (date) => context.read(selectedDate).state =
                            date); //next time you can choose is 31 days next
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )),
        Expanded(
          child: GridView.builder(
              itemCount: TIME_SLOT.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      context.read(selectedTime).state =
                          TIME_SLOT.elementAt(index);
                      context.read(selectedTimeSlot).state = index;
                    },
                    child: Card(
                      color: context.read(selectedTime).state ==
                              TIME_SLOT.elementAt(index)
                          ? Colors.green
                          : Colors.white,
                      child: GridTile(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${TIME_SLOT.elementAt(index)}'),
                              Text('Available')
                            ],
                          ),
                        ),
                        header: context.read(selectedTime).state ==
                                TIME_SLOT.elementAt(index)
                            ? Icon(Icons.check)
                            : null,
                      ),
                    ),
                  )),
        )
      ],
    );
  }

  confirmBooking(BuildContext context) {
    var timeStamp = DateTime(
      context.read(selectedDate).state.year,
      context.read(selectedDate).state.month,
      context.read(selectedDate).state.day,
      int.parse(
        context.read(selectedTime).state.split(':')[0].substring(0, 2),
      ), //hour
      int.parse(
        context.read(selectedTime).state.split(':')[1].substring(0, 2),
      ), //minutes
    ).millisecond;
    var submitData = {
      'ProductId': context.read(selectedProduct).state.docId,
      'ProductName': context.read(selectedProduct).state.name,
      'cityBook': context.read(selectedCity).state.name,
      'customerName': context.read(userInformation).state.name,
      'customerPhone': FirebaseAuth.instance.currentUser.phoneNumber,
      'done': false,
      'warehouseAddress': context.read(selectionWarehouse).state.address,
      'warehouseId': context.read(selectionWarehouse).state.docId,
      'warehouse': context.read(selectionWarehouse).state.name,
      'slot': context.read(selectedTimeSlot).state,
      'timeStamp': timeStamp,
      'time':
          '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}'
    };
    //Submit on FireStore
    context
        .read(selectedProduct)
        .state
        .reference
        .collection(
            '${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}')
        .doc(context.read(selectedTimeSlot).state.toString())
        .set(submitData)
        .then((value)=>(){
      Navigator.of(context).pop();
      ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
        content:Text('Booking Successfully'),
      ));
      //Reset value
      context.read(selectedDate).state = DateTime.now();
      context.read(selectedProduct).state = ProductModel();
      context.read(selectedCity).state = CityModel();
      context.read(selectionWarehouse).state = WareModel();
      context.read(currentStep).state = 1;
      context.read(selectedTime).state = '';
      context.read(selectedTimeSlot).state = -1;
    });
  }

  displayConfirm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(24),
          child: Image.asset('assets/images/logo.png'),
        )),
        Expanded(
            child: Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Thank you for the booking our services!'.toUpperCase(),
                    style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Booking Information'.toUpperCase(),
                    style: GoogleFonts.robotoMono(),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                          '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}'.toUpperCase(),style: GoogleFonts.robotoMono(),)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Icon(Icons.shopping_basket),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                          '${context.read(selectedProduct).state.name}'
                              .toUpperCase(),style: GoogleFonts.robotoMono(),)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(thickness: 1,),
                  Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        '${context.read(selectionWarehouse).state.name}'
                            .toUpperCase(),style: GoogleFonts.robotoMono(),)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        '${context.read(selectionWarehouse).state.address}'
                            .toUpperCase(),style: GoogleFonts.robotoMono(),)
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => confirmBooking(context),
                      child: Text('Confirm'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors
                            .black26),
                      ),

    )

                ],
              ),
            ),
          ),
        ))
      ],
    );
  }
}
