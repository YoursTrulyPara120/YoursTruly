import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:para120/screens/bottom_navigation.dart';
import 'package:para120/screens/digital_locker/locker.dart';
import 'package:para120/screens/main_feature/upload_documents.dart';
import 'package:para120/screens/main_feature/upload_images.dart';
import 'package:para120/screens/main_feature/upload_videos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LockerHome extends StatefulWidget {
  String email;
  LockerHome({this.email});

  @override
  _LockerHomeState createState() => _LockerHomeState();
}

class _LockerHomeState extends State<LockerHome> {

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10,),
                    Text("DocLocker", style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                      textAlign: TextAlign.left,),
                    SizedBox(height: 10,),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Color(0xff9083e8),
                      ),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, CupertinoPageRoute(builder: (context) => DigitalLocker(email: widget.email,)));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 28,),
                            Text("Tap here to add items", style: GoogleFonts.poppins(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      child: Text("Your Documents",style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                        textAlign: TextAlign.left,),
                    ),
                    Container(
                      child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.email)
                            .collection('Digital_Locker')
                            .get(),
                        builder: (context, snapshot){
                          if(snapshot.hasError){
                            return Scaffold(
                              body: Container(
                                child: Text("Error: ${snapshot.error}",),
                              ),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                            // Display the data inside a list view
                            return GridView.builder(
                              itemCount: snapshot.data.docs.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.only(bottom: 20),
                              physics: BouncingScrollPhysics(),

                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.74,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 0.5
                              ),
                              itemBuilder: (context, index){
                                return DownloadCard(
                                  title: snapshot.data.docs[index]['File_Name'],
                                  url: snapshot.data.docs[index]['File_Url'],
                                  path: snapshot.data.docs[index]['Path'],
                                  email: widget.email,
                                  docId: snapshot.data.docs[index].id,
                                );
                              },
                            );
                          }

                          return Scaffold(
                            body: Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        },

                      ),
                    ),

                    Container(
                      child: Text("Recommended",style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                        textAlign: TextAlign.left,),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 33,
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 0),
                                  child: recommendedCard(icon : "assets/aadhar.png",title:  "Aadhar Card")),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 0),
                                  child: recommendedCard(icon : "assets/driving.png",title:  "Driving License")),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 0),
                                  child: recommendedCard(icon : "assets/pan.png",title:  "PAN Card")),

                            ],
                          ),
                        ),

                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 33,
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0),
                                  child: recommendedCard(icon : "assets/10th.png",title:  "Class X Marksheet")),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0),
                                  child: recommendedCard(icon : "assets/12th.png",title:  "Class XII Marksheet")),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0),
                                  child: recommendedCard(icon : "assets/vehicle.png",title:  "Vehicle Insurance")),

                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
          ),
        ),
        // floatingActionButton: Container(
        //   height: 45,
        //   child: FloatingActionButton.extended(
        //       backgroundColor: Color(0xff9083e8),
        //       onPressed: () {
        //         setState(() {
        //
        //         });
        //       },
        //       icon: Icon(
        //         Icons.add,
        //         size: 20,
        //       ),
        //       label: Text(
        //         "Add Documents",
        //         style: GoogleFonts.poppins(
        //           fontSize: 15.0,
        //           color: Colors.white,
        //           fontWeight: FontWeight.w500,
        //         ),
        //       )),
        // ),
      ),
    );
  }


  Widget recommendedCard({String icon, String title, }) {
    return GestureDetector(
      onTap: ()async{
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => DigitalLocker(email: widget.email,)));
      },
      child: Container(
          padding: new EdgeInsets.only(left: 0, top: 0, right: 6),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15,),
                Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Container(
                      width: 90,
                      height: 90,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(icon, fit: BoxFit.cover, ),
                          ],
                        ),
                      ),
                    )
                ),
                Container(
                  width: 90,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(title.split(".").first, style: TextStyle(color: Colors
                        .black, fontWeight: FontWeight.w400, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow. ellipsis, ),
                  ),
                ),
              ]
          )
      ),
    );
  }


}

class DownloadCard extends StatefulWidget {
  String title, url, docId, email, path;
  DownloadCard({this.title, this.url, this.docId, this.email, this.path});

  @override
  _DownloadCardState createState() => _DownloadCardState();
}

class _DownloadCardState extends State<DownloadCard> {

  final Dio _dio = Dio();

  double _progress = 0.0;
  var savePath;
  bool isLoading;



  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: _onSelectNotification);
  }

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        priority: Priority.high,
        importance: Importance.max

    );


    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android,iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? widget.title : 'Failure',
        isSuccess ? '${widget.title} has been downloaded successfully!' : 'There was an error while downloading the file.',
        platform,
        payload: json
    );
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }


  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100);
      });
    }
  }

  Future<void> _startDownload(String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(
          widget.url,
          savePath,
          onReceiveProgress: _onReceiveProgress
      );
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
    }
  }




  @override
  Widget build(BuildContext context) {
    bool _isLoading = isLoading ?? false;

    return GestureDetector(
      onTap: ()async{

        final dir = await _getDownloadDirectory();
        savePath = path.join(dir.path, widget.title);
        // final externalDir = await getExternalStorageDirectory();
        // String savePath = "${externalDir.path}/${widget.title}";

        if(await File(savePath).exists()){
          OpenFile.open(savePath);
        } else{
          setState(() {
            isLoading = true;
          });
          await _startDownload(savePath);
          print(savePath);
          setState(() {
            if(_progress == 100.0){
              FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Digital_Locker").doc(widget.docId).update({
                "Path" : savePath,
              }).then((value) {
                setState(() {
                  isLoading = false;
                });
                Navigator.pushReplacement(
                    context, CupertinoPageRoute(builder: (context) => BottomNavigation(email: widget.email, page: 3,)));
              });
            }
          });
        }},
      child: Container(
          padding: new EdgeInsets.only(left: 0, top: 0, right: 6),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15,),
                Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Container(
                      constraints: new BoxConstraints.expand(
                        width: 90,
                        height: 90,
                      ),
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: new AssetImage(widget.path == "" ? "assets/downloaded.png" : "assets/success.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Visibility(
                            visible: _isLoading ? false : true,
                            child: Container(),
                          ),
                          Visibility(
                            visible: _isLoading,
                            child: Center(
                              child: SizedBox(
                                height: 30.0,
                                width: 30.0,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green,),
                                  value: _progress,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
                // LinearProgressIndicator(
                //   backgroundColor: Colors.grey,
                //   valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                //   value: progress.toDouble(),
                //   minHeight: 5,
                // ),
                Container(
                  width: 90,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(widget.title.split(".").first, style: TextStyle(color: Colors
                        .black, fontWeight: FontWeight.w400, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow. ellipsis, ),
                  ),
                ),
              ],
          ),
      ),
    );
  }
}

