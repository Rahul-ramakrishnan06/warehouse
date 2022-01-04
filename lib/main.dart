import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:wa/screens/booking_screen.dart';
import 'package:wa/screens/home_screen.dart';
import 'package:wa/state/state_management.dart';
import 'package:wa/utils/utils.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //firebase
  Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings){
        switch(settings.name)
        {
          case '/home':
            return PageTransition(
                settings: settings,
                child: HomePage(),
                type: PageTransitionType.fade);
            break;
          case '/booking':
            return PageTransition(
                settings: settings,
                child: BookingScreen(),
                type: PageTransitionType.fade);
            break;
          default:return null;
        }
      },
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}



class MyHomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
 

  processLogin(BuildContext context) {
    var user =FirebaseAuth.instance.currentUser;
    if(user==null)//user not login,showlogin
      {
        FirebaseAuthUi.instance()
            .launchAuth([
              AuthProvider.phone()
        ]).then((firebaseUser)async{
          //refresh state
          context.read(userLogged).state=FirebaseAuth.instance.currentUser;
          //new screen
          //get token here
          await checkLoginState(context,true,scaffoldState);

        }).catchError((e){
          if(e is PlatformException)
            if(e.code == FirebaseAuthUi.kUserCancelledError)
              ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
                  SnackBar(content: Text('${e.message}')));
            else
              ScaffoldMessenger.of(scaffoldState.currentContext).showSnackBar(
                  SnackBar(content: Text('Unk Error')));


        }
        );

      }
    else{//// user already login,start homepage
      

    }
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {

    return Scaffold(
      key:scaffoldState,
      body:Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image:
                AssetImage('assets/images/Industrial.png'),
                fit:BoxFit.cover)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width:MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: checkLoginState(context,false,scaffoldState),
                builder: (context,snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else {
                    var userState = snapshot.data as LOGIN_STATE;
                    if(userState == LOGIN_STATE.LOGGED)
                      {
                        return Container();

                      }
                    else{// If user not login before than return button
                      return ElevatedButton.icon(
                        onPressed: ()=> processLogin(context),
                        icon: Icon(Icons.phone,color: Colors.white,),
                        label: Text('Login With Phone',style: TextStyle(color: Colors.white),),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                      );

                    }
                  }
                }
              )
            )

          ],
        ),
      ),
    );
  }

 Future<LOGIN_STATE> checkLoginState(BuildContext context,bool fromLogin,GlobalKey<ScaffoldState> scaffoldState) async{
    if(!context.read(forceReload).state){
      await Future.delayed(Duration(seconds: fromLogin == true ? 8:3)).then((value)=>{
        FirebaseAuth.instance.currentUser
            .getIdToken()
            .then((token) async {

          //If get token,we print it
          print('$token');
          context.read(userToken).state = token;
          //check user in firestore
          CollectionReference userRef =FirebaseFirestore.instance.collection('User');
          DocumentSnapshot snapshotUser =await userRef
              .doc(FirebaseAuth.instance.currentUser.phoneNumber)
              .get();
          //force reload state
          context.read(forceReload).state= true;
          if(snapshotUser.exists)
          {
            //And because user already login,we will start new screen
            Navigator.pushNamedAndRemoveUntil(context, '/home',(route) => false);
          }
          else{
            //If user info doesnt available , show dialog
            var nameController =TextEditingController();
            var addressController =TextEditingController();
            Alert(
                context:context,
                title:'UPDATE PROFILES',
                content:Column(
                  children: [
                    TextField(decoration: InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Name'
                    ),controller: nameController,),
                    TextField(decoration: InputDecoration(
                        icon: Icon(Icons.home),
                        labelText: 'Address'
                    ),controller: addressController,),
                  ],
                ),
                buttons: [
                  DialogButton(child: Text('Cancel'), onPressed: ()=>Navigator.pop(context)),
                  DialogButton(child: Text('Update'), onPressed: (){
                    //update to the server
                    userRef.doc(FirebaseAuth.instance.currentUser.phoneNumber)
                        .set({
                      'name':nameController.text,
                      'address':addressController.text,

                    }).then((value) async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(scaffoldState.currentContext)
                          .showSnackBar(SnackBar(content: Text('UPDATE PROFILES SUCCESSFULLY')));
                      await Future.delayed(Duration(seconds: 1),(){
                        //AND BECAUSE USER ALREADY LOGIN WE WILL START NEW SCREEN
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      });
                    })
                        .catchError((e){
                      Navigator.pop(context);
                      ScaffoldMessenger.of(scaffoldState.currentContext)
                          .showSnackBar(SnackBar(content: Text('$e')));

                    });
                  }),

                ]
            ).show();
          }

        })
      });
    }
    return FirebaseAuth.instance.currentUser !=null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
 }
}
