import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/auth/Profile.dart';
import 'package:para120/services/routingservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';



/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  final Telephony telephony = Telephony.instance;
  if (timeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email');
  print(email);

  await Firebase.initializeApp();
  QuerySnapshot querySnapshot = await FirebaseFirestore
      .instance
      .collection("users").doc(email).collection("Nominees")
      .get();

  if(querySnapshot.docs.isNotEmpty) {
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      if (a.get('Scheduled_At').toDate().isBefore(DateTime.now()) && a.get('status') == "running") {
        print("if running");
        telephony.sendSms(to: a.get('Number'), message: a.get('Message'));
        await FirebaseFirestore.instance.collection("users").doc(email).collection("Nominees").doc(a.id).update({
          "status": "sent",
        });
      } else {
        print("do nothing");
      }
    }
  }

  QuerySnapshot querySnapshot2 = await FirebaseFirestore
      .instance
      .collection("users").doc(email).collection("Scheduled_Messages")
      .get();

  if (querySnapshot2.docs.isNotEmpty) {
    for (int i = 0; i < querySnapshot2.docs.length; i++) {
      var a = querySnapshot2.docs[i];
      if (a.get('DateTime').toDate().isBefore(DateTime.now()) &&
          a.get('status') == "running") {
        print("if running");
        telephony.sendSms(to: a.get('Number'), message: a.get('Message'));
        await FirebaseFirestore.instance.collection("users").doc(email).collection("Scheduled_Messages").doc(a.id).update({
          "status": "sent",
        });
      } else {
        print("do nothing");
      }
    }
  } else {
    print("do nothing");
  }


  print("[BackgroundFetch] Headless event received: $taskId");


  if (taskId == 'flutter_background_fetch') {
    /* DISABLED:  uncomment to fire a scheduleTask in headlessTask.
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: false,
        stopOnTerminate: false,
        enableHeadless: true
    ));
     */
  }
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await BackgroundFetch.start();
  runApp(MyApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}



class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yours Truly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.comfortable,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      home: RouteBasedOnAuth(),
    );
  }
}

