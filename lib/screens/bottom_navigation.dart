import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:para120/screens/main_feature/Home.dart';
import 'package:para120/screens/digital_locker/locker.dart';
import 'package:para120/screens/message_scheduler/msg_scheduler.dart';
import 'package:para120/screens/main_feature/nominee.dart';
import 'package:para120/screens/message_scheduler/scheduled_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/Profile.dart';
import 'digital_locker/locker_home.dart';
import 'main_feature/choose_nominees.dart';

class BottomNavigation extends StatefulWidget {

  int page;
  String email;
  BottomNavigation({this.page, this.email});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  int index = 0;
  String email;

  @override
  void initState() {
    super.initState();
    getEmail();
    index = widget.page == null ? 0 : widget.page;
  }

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    email = prefs.getString('email');
    print(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPages(),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  Widget buildBody() {
    return Center(
      child: Text("Animated Bottom Navigation", textAlign: TextAlign.center,),
    );
  }

  Widget buildPages(){
     switch(index){
       case 1:
         return ScheduledMessages(email: email,);
       case 2:
         return AllNominees(email: email, from: "Bottom",);
       case 3:
         return LockerHome(email: email == null ? widget.email : email,);
       case 4:
         return ProfileScreen(myProfile: "Profile", email: email,);
       case 0:
       default:
         return HomeScreen(email: email);
    }
  }

  Widget buildBottomNavigation() {
    return BottomNavyBar(
      selectedIndex: index,
        onItemSelected: (index) => setState((){this.index = index;}) ,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              icon: Icon(Icons.apps),
              title: Text("Home"),
              textAlign: TextAlign.center,
              activeColor: Colors.black,
              inactiveColor: Colors.grey),
          BottomNavyBarItem(
              icon: Icon(Icons.timer),
              title: Text("Message"),
              textAlign: TextAlign.center,
              activeColor: Colors.black,
              inactiveColor: Colors.grey),
          BottomNavyBarItem(
              icon: Icon(Icons.people),
              title: Text("Nominee"),
              textAlign: TextAlign.center,
              activeColor: Colors.black,
              inactiveColor: Colors.grey),
          BottomNavyBarItem(
              icon: Icon(Icons.lock),
              title: Text("Doc Locker"),
              textAlign: TextAlign.center,
              activeColor: Colors.black,
              inactiveColor: Colors.grey),
          BottomNavyBarItem(
              icon: Icon(Icons.supervised_user_circle),
              title: Text("Profile"),
              textAlign: TextAlign.center,
              activeColor: Colors.black,
              inactiveColor: Colors.grey)
        ],
    );

  }
}
