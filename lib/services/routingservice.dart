import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:para120/screens/auth/Profile.dart';
import 'package:para120/screens/main_feature/Home.dart';
import 'package:para120/screens/bottom_navigation.dart';
import 'package:para120/screens/auth/login_screen.dart';
import 'package:para120/screens/onboarding/landing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// For OTP Authentication

class RouteBasedOnAuth extends StatefulWidget {
  @override
  _RouteBasedOnAuthState createState() => _RouteBasedOnAuthState();
}

class _RouteBasedOnAuthState extends State<RouteBasedOnAuth> {

  String email;

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      print(email);
    });

  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null)
              return BottomNavigation();
            else
              return Landing();
          }

          return CircularProgressIndicator();
        });
  }
}
// class RoutingBasedOnAuth{
//   checkAuth(){
//     return StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (BuildContext context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return CircularProgressIndicator();
//           if (snapshot.connectionState == ConnectionState.active) {
//             if (snapshot.data != null)
//               return QuizHome();
//             else
//               return LoginScreen();
//           }
//
//           return CircularProgressIndicator();
//         });
//   }
// }
