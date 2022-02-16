import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/main_feature/nominee.dart';
import 'package:para120/screens/main_feature/select_document.dart';


import 'package:para120/services/phone_auth.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/util.dart';
import 'package:para120/widgets/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

import '../auth/login_screen.dart';
import 'choose_nominees.dart';

class HomeScreen extends StatefulWidget {
  String email;

  HomeScreen({this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String email;
  int days;
  final Telephony telephony = Telephony.instance;





  // void _listerForPermission()async{
  //   final statusSMS = await Permission.sms.status;
  //   setState(() {
  //     permissionStatusSMS = statusSMS;
  //   });
  //   switch(statusSMS){
  //     case PermissionStatus.denied :
  //       requestForPermission();
  //       break;
  //
  //     case PermissionStatus.granted :
  //       print("permission granted");
  //       break;
  //
  //     case PermissionStatus.limited :
  //       Navigator.pop(context);
  //       break;
  //
  //     case PermissionStatus.restricted :
  //       Navigator.pop(context);
  //       break;
  //
  //     case PermissionStatus.permanentlyDenied :
  //       Navigator.pop(context);
  //       break;
  //   }
  //
  // }
  //
  // void _listerForPermissionContacts()async{
  //   final statusContacts = await Permission.contacts.status;
  //   setState(() {
  //     permissionStatusContact = statusContacts;
  //   });
  //
  //   switch(statusContacts){
  //     case PermissionStatus.denied :
  //       requestForContacts();
  //       break;
  //
  //     case PermissionStatus.granted :
  //       print("permission granted");
  //       break;
  //
  //     case PermissionStatus.limited :
  //       Navigator.pop(context);
  //       break;
  //
  //     case PermissionStatus.restricted :
  //       Navigator.pop(context);
  //       break;
  //
  //     case PermissionStatus.permanentlyDenied :
  //       Navigator.pop(context);
  //       break;
  //   }
  // }
  //
  // Future<void> requestForPermission() async{
  //   final statusSMS = await Permission.sms.request();
  //   setState(() {
  //     permissionStatusSMS = statusSMS;
  //   });
  //
  // }
  //
  // Future<void> requestForContacts() async{
  //   final statusContacts = await Permission.contacts.request();
  //   setState(() {
  //     permissionStatusContact = statusContacts;
  //   });
  //
  // }


  // getPermissions()async{
  //   await _listerForPermission();
  //   await _listerForPermissionContacts();
  // }

  @override
  void initState() {
    super.initState();
    resetDate();

    // final birthday = DateTime(2021, 08, 23, 10, 45);
    // final date2 = DateTime.now();
    // final difference = birthday.difference(date2).inSeconds;
    // print(difference);

  }

  resetDate()async{
    await getEmail();

    QuerySnapshot querySnapshot = await FirebaseFirestore
        .instance
        .collection("users").doc(email).collection("Nominees")
        .get();

    if(querySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        if (a.get('status') == "running") {
          print("if running");
          await FirebaseFirestore.instance.collection("users").doc(email).collection("Nominees").doc(a.id).update({
            "Scheduled_At": DateTime.now().add(Duration(days: a.get('Total_Days'))),
          });
        } else {
          print("do nothing");
        }
      }
    }
  }

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    email = prefs.getString('email');
    days = prefs.getInt('Days');
    print("Days is $days");
    print("email is $email");
  }



  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          // leading: Padding(
          //   padding: const EdgeInsets.only(top: 12),
          //   child: IconButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(
          //       Icons.arrow_back_ios,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          title: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Yours Truly',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            Container(
              alignment: Alignment.bottomCenter,
              child: IconButton(
                icon: SvgPicture.asset("assets/ic_notification.svg"),
                alignment: Alignment.center,
                onPressed: () =>
                {
                  Utils.toast("Notification"),
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 30,),
                Text("Welcome to", style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),),
                SizedBox(height: 10,),
                Text("Yours Truly", style: GoogleFonts.poppins(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),),
                SizedBox(height: 100,),
                Text("Write your secret message that you always wanted to share with your loved one and set the timeline so that we'll send that message to your loved one once you inactive in this app", style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                Container(
                  height: 3,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Color(0xff9083e8),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 150.0),
                  child: BtnGradient(
                      top: 0, left: 28, bottom: 28, right: 28,
                      onTap: () async {
                        if(email != null){
                          Navigator.push(
                              context, CupertinoPageRoute(builder: (context) => AllNominees(email: email,)));
                        } else{
                          Utils.flushbar(context, "Check Internet Connection", "Internet Connection is required to run this feature");
                        }
                      },
                      text: "Get Started"
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}


