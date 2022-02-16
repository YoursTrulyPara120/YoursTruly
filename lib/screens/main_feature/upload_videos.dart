import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:para120/screens/main_feature/select_document.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/util.dart';
import 'package:para120/widgets/video_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class UploadVideos extends StatefulWidget {
  String userEmail, nomineeEmail;
  UploadVideos({this.userEmail, this.nomineeEmail});

  @override
  _UploadVideosState createState() => _UploadVideosState();
}

class _UploadVideosState extends State<UploadVideos> {

  var _videoPlayerController;
  final _formKey = GlobalKey<FormState>();
  bool _loginFormLoading = false;
  File _video;
  final picker = ImagePicker();
  final storage = FirebaseStorage.instance;




  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          title: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Upload Videos',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 4.0,
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  GestureDetector(
                      onTap: ()async {
                        _showPicker(context);
                      },
                      child: Utils.getUploadWidget()
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text('Upload Videos', style: GoogleFonts.poppins(
                      fontSize: 14.0, color: Colors.grey),
                      textAlign: TextAlign.right),
                  SizedBox(
                    height: _video == null ? 50.0 : 0.0,
                  ),
                    _video != null ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoItems(
                        key: UniqueKey(),
                        videoPlayerController: VideoPlayerController.file(_video),
                        looping: false,
                        autoplay: true,
                      ),
                    ) : Text("No Video Selected", style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
                    // _videoPlayerController.value.initialized
                    //     ? AspectRatio(
                    //   aspectRatio: _videoPlayerController.value.aspectRatio,
                    //   child: VideoPlayer(_videoPlayerController),
                    // )
                    //     : Container()



                  BtnGradient(
                    top: _video == null ? 100.0 : 20.0,
                    left: 12.0,
                    bottom: 4.0,
                    right: 10.0,
                    text: 'Submit',
                    isLoading: _loginFormLoading,
                    onTap: () async {
                      print("Running");
                      //_startprogress();
                      if(_video == null){
                        Utils.flushbar(context, "Select Video", 'Please select atleast one video');
                      }else{
                        uploadVideo();
                      }


                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void uploadVideo()async{
    setState(() {
      _loginFormLoading = true;
    });

    var snapshot = storage.ref().child('${widget.userEmail}/Nominee/videos/video');
    await snapshot.putFile(_video);
    var imgUrl = await snapshot.getDownloadURL();

    CollectionReference users = FirebaseFirestore.instance.collection('users/${widget.userEmail}/Nominees/');
    users.doc(widget.nomineeEmail).update({
      'Videos' : FieldValue.arrayUnion([imgUrl]),
    }).then(
          (value)  {
            setState(() {
              _loginFormLoading = false;
            });
            Navigator.pushReplacement(context, new CupertinoPageRoute(
                builder: (context) =>
                    SelectDocument(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));
      },
    ).
    catchError((error) {
      print("Check your Internet connection: $error");
    });


  }



// This funcion will helps you to pick a Video File
  _pickVideo() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.gallery);
    setState(() {
      _video = File(pickedFile.path);
      print(_video);
      _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
        // _videoPlayerController.play();
      });
    });


  }

  // This funcion will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {

    PickedFile pickedFile = await picker.getVideo(source: ImageSource.camera);
    setState(() {
      _video = File(pickedFile.path);
      _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
        // setState(() { });
        // _videoPlayerController.play();
      });
    });

  }


  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        _pickVideo();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: new Icon(Icons.photo_camera),
                      title: new Text('Camera'),
                      onTap: () {
                        _pickVideoFromCamera();
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }


}
