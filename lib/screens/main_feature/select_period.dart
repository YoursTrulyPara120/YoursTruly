import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/bottom_navigation.dart';
import 'package:para120/screens/main_feature/Home.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/single_selectable_card.dart';
import 'package:para120/widgets/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart' as smsSender;

class SelectPeriod extends StatefulWidget {
  String userEmail, nomineeEmail;
  SelectPeriod({this.userEmail, this.nomineeEmail});


  @override
  _SelectPeriodState createState() => _SelectPeriodState();
}

class _SelectPeriodState extends State<SelectPeriod> {
  List periodDays = ["7 Days", "14 Days", "21 Days"];
  String selectedPeriodDay;
  int periodDay;

  List graceDays = ["5 Days"];
  String selectedGraceDay;
  int graceDay;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final smsSender.Telephony telephony = smsSender.Telephony.instance;


  Future<void> schedulePeriod() async {
    // Load persisted fetch events from SharedPreferences
    // Configure BackgroundFetch.
    try {
      var status = await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        forceAlarmManager: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,

      ), (String taskId) async{
        if (taskId == "flutter_background_fetch") {
          QuerySnapshot querySnapshot = await FirebaseFirestore
              .instance
              .collection("users").doc(widget.userEmail).collection("Nominees")
              .get();

          if(querySnapshot.docs.isNotEmpty) {
            for (int i = 0; i < querySnapshot.docs.length; i++) {
              var a = querySnapshot.docs[i];
              if (a.get('Scheduled_At').toDate().isBefore(DateTime.now()) &&
                  a.get('status') == "running") {
                print("if running");
                telephony.sendSms(to: a.get('Number'), message: a.get('Message'));
                await FirebaseFirestore.instance.collection("users").doc(widget.userEmail).collection("Nominees").doc(a.id).update({
                  "status": "sent",
                });
              } else {
                print("do nothing");
              }
            }
          }

          QuerySnapshot querySnapshot2 = await FirebaseFirestore
              .instance
              .collection("users").doc(widget.userEmail).collection("Scheduled_Messages")
              .get();


          if (querySnapshot2.docs.isNotEmpty) {
            for (int i = 0; i < querySnapshot2.docs.length; i++) {
              var a = querySnapshot2.docs[i];
              if (a.get('DateTime').toDate().isBefore(DateTime.now()) &&
                  a.get('status') == "running") {
                print("if running");
                telephony.sendSms(to: a.get('Number'), message: a.get('Message'));
                await FirebaseFirestore.instance.collection("users").doc(widget.userEmail).collection("Scheduled_Messages").doc(a.id).update({
                  "status": "sent",
                });
              } else {
                print("do nothing");
              }
            }
          } else {
            print("do nothing");
          }
        } else{
          print("do nothing");
        }
        BackgroundFetch.finish(taskId);
      }, _onBackgroundFetchTimeout);
      print('[BackgroundFetch] configure success: $status');
    } catch(e) {
      print("[BackgroundFetch] configure ERROR: $e");

    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
          ),
          // title: Padding(
          //   padding: const EdgeInsets.only(top: 12),
          //   child: Text(
          //     'Select Period',
          //     style: GoogleFonts.poppins(
          //       fontSize: 20.0,
          //       fontWeight: FontWeight.w500,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Select Period',
                style: GoogleFonts.poppins(
                  fontSize: 22.0,
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
              child: Text(
                'Here period stand for the time interval in which you have to show your presence. Application keep on tracking your presence. In case you did not turn up then application grace period will start.',
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableCard(
                options: periodDays,
                gridCount: 3,
                onSelected: (day){
                  selectedPeriodDay = day;
                  periodDay = int.tryParse(day.split(" ").first);
                  print(periodDay);
                },
                height: 1.2,
              ),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Select Grace Period',
                style: GoogleFonts.poppins(
                  fontSize: 22.0,
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
              child: Text(
                'If you did not turn up and show your presence in the application based on the period you have selected then your grace period start. You will start receiving messages & calls from us as a reminder.',style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 115, right: 115),
              child: SelectableCard(
                options: graceDays,
                gridCount: 1,
                onSelected: (day){
                  selectedGraceDay = day;
                  graceDay = int.tryParse(day.split(" ").first);
                  print(graceDay);
                },
                height: 1.2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: BtnGradient(
                top: 30.0,
                left: 12.0,
                bottom: 4.0,
                right: 10.0,
                text: 'Submit',
                onTap: () async {
                  print("Running");
                  if (selectedPeriodDay == null) {
                    Utils.flushbar(context, "Select Period", 'Please select atleast one option in period');
                  }else if(selectedGraceDay == null){
                    Utils.flushbar(context, "Select Grace Period", 'Please select atleast one option in grace period');
                  }else if(selectedPeriodDay == null && selectedGraceDay == null){
                    Utils.flushbar(context, "Select Above Details", 'Please select atleast one option in both period');
                  }else{
                    print(periodDay + graceDay);
                    await FirebaseFirestore.instance.collection("users").doc(widget.userEmail).collection("Nominees").doc(widget.nomineeEmail).update({
                      "Period_Days" : periodDay,
                      "Grace_Period_Days" : graceDay,
                      "Total_Days" : periodDay + graceDay,
                      "Scheduled_At" : DateTime.now().add(Duration(days: (periodDay + graceDay))),
                      "status" : "running",
                    });
                    schedulePeriod();
                    Navigator.pushReplacement(
                        context, CupertinoPageRoute(builder: (context) =>
                        BottomNavigation(email: widget.userEmail, page: 0,)));
                  }
                }
              ),
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
