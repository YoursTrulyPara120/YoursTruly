import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:para120/screens/main_feature/select_document.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/dottedborder/dotted_border.dart';
import 'package:para120/widgets/util.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../fullscreen_img.dart';


class UploadImages extends StatefulWidget {
  String userEmail, nomineeEmail;
  UploadImages({this.userEmail, this.nomineeEmail});

  @override
  _UploadImagesState createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  final storage = FirebaseStorage.instance;
  String base64Image = "";

  Image imgFile;
  PickedFile imagegot;
  ImagePicker _picker;
  List<String> base64List = [];
  String _path;
  Map<String, String> _paths;
  bool _loginFormLoading = false;
  List<String> imgUrlList = [];
  List<Asset> resultList;



  final _formKey = GlobalKey<FormState>();

  Future<void> connectivityChecker() async {
    var connected = false;
    print("Checking internet...");
    try {
      final result = await InternetAddress.lookup('google.com');
      final result2 = await InternetAddress.lookup('facebook.com');
      final result3 = await InternetAddress.lookup('microsoft.com');
      if ((result.isNotEmpty && result[0].rawAddress.isNotEmpty) ||
          (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) ||
          (result3.isNotEmpty && result3[0].rawAddress.isNotEmpty)) {
        print('connected..');
        connected = true;
      } else {
        print("not connected from else..");
        _showdialog();
        connected = false;
      }
    } on SocketException catch (_) {
      print('not connected...');
      _showdialog();
      connected = false;
    }
    // return connected;
  }





  void _showdialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('ERROR'),
            content: Text("No Internet Detected."),
            actions: <Widget>[
              FlatButton(
                // method to exit application programitacally
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }




  @override
  void initState() {
    _picker = ImagePicker();
    super.initState();
    connectivityChecker();

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                'Upload Images',
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
                        onTap: () {
                          loadAssets();
                        },
                        child: Utils.getUploadWidget()
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Upload Multiple Images', style: GoogleFonts.poppins(
                        fontSize: 14.0, color: Colors.grey),
                        textAlign: TextAlign.right),
                    SizedBox(
                      height: 50.0,
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          child: DottedBorder(
                            color: Colors.orange,
                            strokeWidth: 1,
                            dashPattern: [8, 5],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            padding: EdgeInsets.all(6),
                            child: Container(
                                padding: EdgeInsets.all(2.0),
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: showImage()
                              // showImage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    BtnGradient(
                      top: 40.0,
                      left: 12.0,
                      bottom: 4.0,
                      right: 10.0,
                      text: 'Submit',
                      isLoading: _loginFormLoading,
                      onTap: () async {
                        print("Running");
                        //_startprogress();
                        if (base64List.length == 0) {
                          Utils.flushbar(context, "Upload Images",
                              "Please upload at least one image");
                        } else {
                          //uploadImages();
                          // Navigator.push(context, CupertinoPageRoute(builder: (context) => CashlessClaim17A(finalmail: widget.finalmail,hospitalEmail :widget.hospitalEmail,option: widget.option,
                          //     option2: widget.option2, finalcase: widget.finalcase)));


                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget showImage() {
    return base64List.length > 0 ? GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
        mainAxisSpacing: 0,
        shrinkWrap: true,
        children: List.generate(base64List.length, (index) {
          return Stack(
              children: [
                GestureDetector(
                  onTap: () =>
                  {
                    Navigator.push(context, new CupertinoPageRoute(
                        builder: (context) =>
                            FullScreenImg(img: base64List[index])))
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0, color: Utils.getPrimaryColor())
                    ),
                    child: Center(
                      child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Image.memory(base64.decode(base64.normalize(
                              base64List[index])), width: 100, height: 100)
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                  (
                      setState(() {
                        base64List.removeAt(index);
                      })
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: SvgPicture.asset(
                            "assets/ic_close_red.svg", width: 24, height: 24)
                    ),
                  ),
                )
              ]
          );
        })
    ) : Padding(
      padding: EdgeInsets.all(12.0),
      child: Center(
          child: Text('No Image uploaded', style: TextStyle(fontSize: 20))),
    );
  }




  testCompressAndGetFile(String file, int counter) async {

    Utils.toast('Please Wait');
    setState(() {
      _loginFormLoading = true;
    });

    var result = await FlutterNativeImage.compressImage(
      file,
      quality: 80,
    );

    //print(admission);

    var snapshot = storage.ref().child("/cases//Consultation Paper/Consultation Paper $counter");
    await snapshot.putFile(result);
    //print(admission.toString());
    var imgUrl = await snapshot.getDownloadURL();

    imgUrlList.add(imgUrl);
    print(imgUrlList);

    CollectionReference users = FirebaseFirestore.instance.collection('users/${widget.userEmail}/Nominees/');
    users.doc(widget.nomineeEmail).update({
      'Photos': FieldValue.arrayUnion(imgUrlList),
    }).then((value) {
      if(resultList.length == imgUrlList.length){
        setState(() {
          _loginFormLoading = false;
        });
        Navigator.pushReplacement(context, new CupertinoPageRoute(
            builder: (context) =>
                SelectDocument(userEmail: widget.userEmail, nomineeEmail: widget.nomineeEmail,)));
      }


    },
    ).
    catchError((error) {
      print("Check your Internet connection: $error");
      Utils.toast('something went wrong');

    });
  }

  Future<void> loadAssets() async {

    String error;
    Uint8List _bytesImage;
    imgUrlList.clear();


    try {
      _path = null;
      resultList = await MultiImagePicker.pickImages(
          maxImages: 25,
          enableCamera: true
      );
    } on Exception catch (e) {
      error = e.toString();
      print('the error is $error');
    }



    if (!mounted) return;

    if (resultList.isNotEmpty) {

      int counter = 1;
      List<String> testList = List();
      for (Asset image in resultList) {


        var result;
        FlutterAbsolutePath.getAbsolutePath(image.identifier).then((value) => {
          print("this is value $value"),
          testCompressAndGetFile(value,counter),

        });

        if (image != null) {

          ByteData byteData = await image.getByteData(quality: 80);
          base64Image = base64Encode(byteData.buffer.asUint8List());
          testList.add(base64Image);



        }
        counter = counter + 1;
      }

      setState(() {
        base64List.addAll(testList);
        if (error == null) print('No Error Detected');
      });
    }
  }
}