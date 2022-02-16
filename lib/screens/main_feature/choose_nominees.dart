import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:para120/screens/main_feature/nominee.dart';
import 'package:para120/screens/main_feature/select_document.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:url_launcher/url_launcher.dart';

class AllNominees extends StatefulWidget {
  String email;
  String from;
  AllNominees({this.email, this.from});

  @override
  _AllNomineesState createState() => _AllNomineesState();
}

class _AllNomineesState extends State<AllNominees> {

  Stream allNomineesStream;

  Widget nomineesList() {
    return SingleChildScrollView(
      child: Container(
          child: Column(
            children: [
              StreamBuilder(
                  stream: allNomineesStream,
                  builder: (context, snapshot) {
                    return snapshot.data == null
                        ? Container(
                      alignment: Alignment.center,
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
                          nomineeName: snapshot.data.docs[index].data()["Name"],
                          number: snapshot.data.docs[index].data()["Number"],
                          nomineeEmail: snapshot.data.docs[index].data()["Email"],
                          nomineePassword: snapshot.data.docs[index].data()["Password"],
                          relation: snapshot.data.docs[index].data()["Relation"],
                          other: snapshot.data.docs[index].data()["Other"],
                          userEmail: widget.email,

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
    getNomineeList().then((result) {
      setState(() {
        allNomineesStream = result;
      });
    });
  }

  getNomineeList() async{
    return await FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Nominees").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: widget.from != "Bottom" ? Padding(
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
        ) : Container(),
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            widget.from == "Bottom" ? 'Your Nominees' : "Choose Nominees",
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
                padding: const EdgeInsets.only(top: 20.0),
                child: nomineesList(),
              ),
              // widget.from != "Bottom" ? Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 20),
              //   child: BtnGradient(
              //     top: 150.0,
              //     left: 6.0,
              //     bottom: 30.0,
              //     right: 6.0,
              //     onTap: () async {
              //       Navigator.push(
              //       context, CupertinoPageRoute(builder: (context) => SelectDocument(email: widget.email,)));
              //     },
              //     text: 'Submit',
              //   ),
              // ) : Container(),
              SizedBox(height: 50,),
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
                  context, CupertinoPageRoute(builder: (context) => NomineeScreen(email: widget.email,)));
            },
            icon: Icon(
              Icons.add,
              size: 20,
            ),
            label: Text(
              "Add Nominee",
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
  String imgUrl, nomineeName, nomineeEmail, nomineePassword, number, userEmail, relation, other;
  Future<void> launched;
  String launchUrl;

  NomineesListTile(
      {@required this.imgUrl,
        @required this.nomineeName,
        @required this.number,
      this.nomineeEmail, this.nomineePassword, this.userEmail, this.relation, this.other,});

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
    return GestureDetector(
      onTap: (){
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => SelectDocument(userEmail: userEmail, contact: number, nomineeEmail: nomineeEmail,)));
      },
      child: Container(
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
                                  nomineeName,
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
                              Text(
                                nomineeEmail,
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                nomineePassword,
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),



                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  launched = _makePhoneCall('tel:$number');
                                },
                                child: Container(
                                  padding:
                                  EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                                  width: 80.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.indigo, width: 1),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.call,
                                        size: 16,
                                        color: Colors.indigo,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Call",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context, CupertinoPageRoute(builder: (context) => NomineeScreen(email: userEmail, nomineeName: nomineeName, nomineeEmail: nomineeEmail, nomineePassword: nomineePassword, number: number, selectedRelation: relation, other: other,)));
                                },
                                child: Container(
                                  padding:
                                  EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                                  width: 80.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.indigo, width: 1),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.indigo,
                                      ),
                                      SizedBox(width: 5.0),
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.indigo),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
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
      ),
    );
  }
}

