import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/main_feature/nominee.dart';
import 'package:para120/screens/main_feature/select_period.dart';
import 'package:para120/screens/main_feature/upload_documents.dart';
import 'package:para120/screens/main_feature/upload_images.dart';
import 'package:para120/screens/main_feature/upload_videos.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/custom_text_field.dart';
import 'package:para120/widgets/util.dart';

class SelectDocument extends StatefulWidget {
  String userEmail, nomineeEmail;
  String contact;
  SelectDocument({this.userEmail, this.contact, this.nomineeEmail});


  @override
  _SelectDocumentState createState() => _SelectDocumentState();
}

class _SelectDocumentState extends State<SelectDocument> {

  String message;
  List photos = [''];
  List audios = [''];
  List videos = [''];
  List documents = [''];
  final _formKey = GlobalKey<FormState>();


  fetchLengthOfDocuments()async{
    await FirebaseFirestore.instance.collection("users").doc(widget.userEmail).collection("Nominees").doc(widget.nomineeEmail).get().then((doc){
      setState(() {
        photos = doc.data()['Photos'];
        audios = doc.data()['Audios'];
        videos = doc.data()['Videos'];
        documents = doc.data()['Documents'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLengthOfDocuments();
  }

  @override
  Widget build(BuildContext context) {
    print("email is ${widget.userEmail}");
    return Scaffold(
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
          ) ,
          title: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Upload Documents',
              style: GoogleFonts.poppins(
                fontSize: 21.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context, CupertinoPageRoute(builder: (context) => UploadImages(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 0),
                        child: buildCard(icon : "assets/photos.png",title:  "Photos", noOfFiles: photos.length)),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 0),
                        child: buildCard(icon : "assets/audio.png",title:  "Audio")),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context, CupertinoPageRoute(builder: (context) => UploadVideos(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));
                      },
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0),
                          child: buildCard(icon : "assets/video.png",title:  "Videos", noOfFiles: videos.length)),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context, CupertinoPageRoute(builder: (context) => UploadDocuments(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));
                      },
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0),
                          child: buildCard(icon : "assets/document.png",title:  "Document", noOfFiles: documents.length)),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                _buildMessageField(),
                Spacer(),
                BtnGradient(
                  top: 0.0,
                  left: 12.0,
                  bottom: 30.0,
                  right: 10.0,
                  text: 'Next',
                  onTap: () async {
                    if(photos.length == 0 && audios.length == 0 && videos.length == 0 && documents.length == 0){
                      Utils.flushbar(context, "Upload Files", 'Please upload atleast one file');
                    } else if (_formKey.currentState.validate()){
                      await FirebaseFirestore.instance.collection("users").doc(widget.userEmail).collection("Nominees").doc(widget.nomineeEmail).update({
                        "Message" : message,
                      });
                      await FirebaseFirestore.instance.collection("nominees").doc(widget.nomineeEmail).update({
                        "Message" : message,
                      });
                      Navigator.push(
                          context, CupertinoPageRoute(builder: (context) => SelectPeriod(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));

                    }

                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard({String icon, String title, int noOfFiles = 0}) {
    return Container(
        padding: new EdgeInsets.only(left: 0, top: 0, right: 6),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15,),
              Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: Image.asset(icon, height: 63, width: 63,)
              ),
              Text(title, style: TextStyle(color: Colors
                  .black, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,),
              Text("$noOfFiles", style: TextStyle(color: Colors
                  .black, fontWeight: FontWeight.w500, fontSize: 15), textAlign: TextAlign.center,) ,
            ]
        )
    );
  }

  _buildMessageField() {
    return CustomTextField(
      validator: (value) {
        return Utils.validateField(value);
      },
      onChanged: (value) {
        setState(() {
          message = value;
        });

      },
      labelText: 'Your Message',
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.newline,
      maxLines: 5,
      borderRadius: 10,
      editable: false,
    );
  }
}





