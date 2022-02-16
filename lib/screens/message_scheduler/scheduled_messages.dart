import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:para120/screens/main_feature/nominee.dart';
import 'package:para120/screens/main_feature/select_document.dart';
import 'package:para120/screens/message_scheduler/msg_scheduler.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledMessages extends StatefulWidget {
  String email;
  String from;
  ScheduledMessages({this.email, this.from});

  @override
  _ScheduledMessagesState createState() => _ScheduledMessagesState();
}

class _ScheduledMessagesState extends State<ScheduledMessages> {

  Stream scheduledMessagesStream;

  Widget scheduledMessageList() {
    return SingleChildScrollView(
      child: Container(
          child: Column(
            children: [
              StreamBuilder(
                  stream: scheduledMessagesStream,
                  builder: (context, snapshot) {
                    return snapshot.data == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            //padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: snapshot.data.docs.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                          return NomineesListTile(
                            imgUrl: "assets/aadhar.png",
                            name: snapshot.data.docs[index].data()["Name"],
                            number: snapshot.data.docs[index].data()["Number"],
                            date: snapshot.data.docs[index].data()["Date"],
                            time: snapshot.data.docs[index].data()["Time"],
                            message: snapshot.data.docs[index].data()["Message"],
                            msgId: snapshot.data.docs[index].data()["MsgId"],
                            docId: snapshot.data.docs[index].id,
                            email: widget.email,
                        );
                      },
                    );
                  })
            ],
          )),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getScheduledMessageList().then((result) {
      setState(() {
        scheduledMessagesStream = result;
      });
    });
  }

  getScheduledMessageList() async{
    return await FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Scheduled_Messages").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    print("email is ${widget.email}");

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            "Scheduled Messages",
            style: GoogleFonts.poppins(
              fontSize: 21.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
                child: scheduledMessageList(),
              ),
            ] ,
          ),
        ),
      ),

      floatingActionButton: Container(
        height: 45,
        child: FloatingActionButton.extended(
            backgroundColor: Color(0xff9083e8),
            onPressed: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => MsgScheduler(email: widget.email,)));
            },

            icon: Icon(
              Icons.add,
              size: 20,
            ),
            label: Text(
              "Schedule Message",
              style: GoogleFonts.poppins(
                fontSize: 15.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )),
      ),
    );
  }
}



class NomineesListTile extends StatelessWidget {
  String imgUrl, name, date, time, number, message, msgId, docId, email;
  Future<void> launched;
  String launchUrl;

  NomineesListTile(
      {@required this.imgUrl,
        @required this.name,
        @required this.number,
        this.date, this.time, this.message, this.msgId, this.docId, this.email});

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Future<void> _launchInApp(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(
  //       url,
  //       forceSafariVC: true,
  //       forceWebView: false,
  //       headers: <String, String>{'header_key': 'header_value'},
  //     );
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Container(
                              width: 200,
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 200,
                              child: Text(
                                "Scheduled at $date, $time",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                            onTap: (){
                              BackgroundFetch.finish(msgId);
                              FirebaseFirestore.instance.collection("users").doc(email).collection("Scheduled_Messages").doc(docId).delete();
                            },
                            child: Icon(Icons.delete_rounded, color: Colors.red,)),
                        // Column(
                        //   children: [
                        //     Text(
                        //       date,
                        //       style: TextStyle(
                        //           color: Colors.black87, fontSize: 14),
                        //       maxLines: 1,
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //     SizedBox(height: 3.0),
                        //     Text(
                        //       time,
                        //       style: TextStyle(
                        //           color: Colors.black87, fontSize: 14),
                        //       maxLines: 1,
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   left: 20.0,
                //   top: 15.0,
                //   bottom: 15.0,
                //   child: ClipRRect(
                //       borderRadius: BorderRadius.circular(20.0),
                //       child: CachedNetworkImage(
                //         imageUrl: imgUrl,
                //         width: 100,
                //         fit: BoxFit.cover,
                //       )),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

