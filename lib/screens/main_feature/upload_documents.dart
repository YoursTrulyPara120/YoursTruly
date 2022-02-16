import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/main_feature/select_document.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadDocuments extends StatefulWidget {
  String userEmail, nomineeEmail;
  UploadDocuments({this.userEmail, this.nomineeEmail});

  @override
  _UploadDocumentsState createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {


  final _formKey = GlobalKey<FormState>();
  bool _loginFormLoading = false;



  @override
  void initState() {
    super.initState();

  }

  Map<String, String> _paths;
  List path = [''];
  String _extension;
  List<String> filesUrlList = [];

  void openFileExplorer() async {
    path.clear();
    filesUrlList.clear();
    try {
      _paths = await FilePicker.getMultiFilePath(fileExtension: _extension);
      print(_paths);

      setState(() {
        _paths.forEach((k, v) => path.add(_paths[k].toString()));
      });

      uploadToFirebase();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }

  uploadToFirebase() {
    int counter = 1;
    _paths.forEach((fileName, filePath) => {upload(fileName, filePath, counter),
      counter = counter + 1,
    });
  }

  upload(fileName, filePath, int counter)async {

    setState(() {
      _loginFormLoading = true;
    });


    _extension = fileName.toString().split('.').last;
    Reference storageRef = FirebaseStorage.instance.ref().child('${widget.userEmail}/Documents/Document $counter');
    await storageRef.putFile(File(filePath),);
    var imgUrl = await storageRef.getDownloadURL();

    filesUrlList.add(imgUrl);
    print(filesUrlList);

    CollectionReference users = FirebaseFirestore.instance.collection('users/${widget.userEmail}/Nominees');
    users.doc(widget.nomineeEmail).update({
      'Documents':FieldValue.arrayUnion(filesUrlList),
    }).then((value) {
      if(path.length == filesUrlList.length){
        setState(() {
          _loginFormLoading = false;
        });
        Navigator.pushReplacement(context, new CupertinoPageRoute(
            builder: (context) =>
                SelectDocument(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> children = <Widget>[];

    final Widget tile = UploadTaskListTile(
        paths: path
    );
    children.add(tile);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
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
              'Upload Files',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Form(
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
                    onTap: () {
                      openFileExplorer();
                    },
                    child: Utils.getUploadWidget()
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text('Upload Files', style: GoogleFonts.poppins(
                    fontSize: 14.0, color: Colors.grey),
                    textAlign: TextAlign.right),
                SizedBox(
                  height: 50.0,
                ),

                Container(
                  height: 300,
                  child: ListView(
                    shrinkWrap: true,
                    children: children,
                  ),
                ),


                BtnGradient(
                  top: 20.0,
                  left: 12.0,
                  bottom: 4.0,
                  right: 10.0,
                  text: 'Submit',
                  isLoading: _loginFormLoading,
                  onTap: () async {
                    print("Running");
                    //_startprogress();
                    if(filesUrlList.length == 0){
                      Utils.flushbar(context, "Select Video", 'Please select atleast one video');
                    }else{

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
}


class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key, this.task, this.onDismissed, this.onDownload, this.title, this.paths})
      : super(key: key);

  final UploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onDownload;
  final title;
  final List paths;


  double roundDouble(double value, int places){
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child:
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: paths.length ,
          itemBuilder: (BuildContext context, int index){
            final int fileNo = index + 1;
            final String name =
            paths[index].toString();
            final String splitedName = paths[0] == '' ? 'No File Selected' : 'File $fileNo : ' + name.split("/").last;
            //final filePath = paths.values.toList()[index].toString();
            return ListTile(
              title: Text(splitedName),
              //subtitle: subtitle,
            );
          },
          //separatorBuilder: (BuildContext context, int index) => new Divider(),
        ),

      ),
    );

  }
}
