import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:para120/screens/bottom_navigation.dart';
import 'package:para120/screens/digital_locker/locker_home.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/custom_text_field.dart';
import 'package:para120/widgets/dottedborder/dotted_border.dart';
import 'package:para120/widgets/util.dart';
import 'package:path_provider/path_provider.dart';

import '../fullscreen_img.dart';

class DigitalLocker extends StatefulWidget {

  String email;

  DigitalLocker({this.email});

  @override
  _DigitalLockerState createState() => _DigitalLockerState();
}

class _DigitalLockerState extends State<DigitalLocker> {

  String _path;
  String _extension;
  List<String> filesUrlList = [];
  bool _loginFormLoading = false;
  String fileName;

  File imgFile;
  String base64Image = "";
  String errMessage = 'Error Uploading Image';
  String selectedRelation = "1";
  bool showSpinner = false;
  ImagePicker _picker;
  var selectedCurrency, selectedType;

  final storage = FirebaseStorage.instance;

  String renamedFile;



  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _picker = ImagePicker();
    super.initState();

  }

  void openFileExplorer() async {
    try {
      _path = await FilePicker.getFilePath(fileExtension: _extension);
      setState(() {
        fileName = _path.toString().split('/').last;
        print('single file is $_path $fileName');
      });

    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }

  upload(filePath)async {
    setState(() {
      _loginFormLoading = true;
    });

    Reference storageRef = FirebaseStorage.instance.ref().child('${widget.email}/$fileName');
    await storageRef.putFile(File(filePath),);
    var imgUrl = await storageRef.getDownloadURL();

    print(imgUrl);

    print('document file name is ${fileName}');

    CollectionReference users = FirebaseFirestore.instance.collection('users/${widget.email}/Digital_Locker/');
    users.doc().set({
      'File_Url': imgUrl,
      'File_Name' : '$renamedFile.${fileName.split(".").last}',
    }).then((value) {
      setState(() {
        _loginFormLoading = false;
      });
      Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (context) => BottomNavigation(page: 3, email: widget.email,)));
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.email);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 100.0,
                  ),
                  Text('Upload Documents',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 22.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Utils.getUploadWidget()
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text('Upload Documents', style: GoogleFonts.poppins(
                      fontSize: 14.0, color: Colors.grey),
                      textAlign: TextAlign.right),
                  SizedBox(
                    height: 50.0,
                  ),
                  _path == null ? Stack(
                    children: [
                      Container(
                        height: 150,
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
                  ) : Text(fileName,style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),),
                  Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: _buildFileRenameField()
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
                      if (_path == null && base64Image == "") {
                        Utils.flushbar(context, "Upload File",
                            "Please upload at least one file");
                      } else if(_path != null && base64Image == "" && _formKey.currentState.validate()){
                        upload(_path);
                      } else if(_path == null && base64Image != "" && _formKey.currentState.validate()){
                        uploadImage();
                      } else{
                        Utils.flushbar(context, "File Name is Empty",
                            "Please give a file name");
                      }
                    },
                  )
                ],
              ),
            )
          ),
        ),
      ),

    );
  }

  void uploadImage() async {
    setState(() {
      _loginFormLoading = true;
    });

    var snapshot = storage.ref().child('null/cases/${imgFile.path.split("/").last}');
    await snapshot.putFile(imgFile);
    var imgUrl = await snapshot.getDownloadURL();
    print('image file name is ${imgFile.path.split("/").last}');

    CollectionReference users = FirebaseFirestore.instance.collection('users/${widget.email}/Digital_Locker/');
    users.doc().set({
      'File_Url':imgUrl ,
      'File_Name' : '$renamedFile.${imgFile.path.split("/").last.split(".").last}',
      'Path' : "",
    }).then(
          (value)  {
            setState(() {
              _loginFormLoading = false;
            });
            Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (context) => BottomNavigation(page: 3, email: widget.email,)));
      },
    ).
    catchError((error) {
      print("Check your Internet connection: $error");
    });

  }

  Widget showImage() {

    return base64Image != "" ? Stack(
        children:[
          GestureDetector(
            onTap: () => {
              Navigator.push(context, new CupertinoPageRoute(builder: (context) => FullScreenImg(img: base64Image)))
            },
            child: Center(
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Image.memory(base64.decode(base64.normalize(base64Image)))

              ),
            ),
          ),

          GestureDetector(
            onTap: () => (
                setState(() {
                  base64Image = "";
                })
            ),
            child: Align(
                alignment: Alignment.topRight,
                child: SvgPicture.asset("assets/ic_close_red.svg", width: 24, height: 24,)
            ),
          )
        ]
    ): Padding(
      padding: EdgeInsets.all(12.0),
      child: Center(
          child: Text('No File Selected', style: TextStyle(fontSize: 20))),
    );
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
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: new Icon(Icons.photo_camera),
                      title: new Text('Camera'),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: new Icon(Icons.photo_camera),
                      title: new Text('Documents'),
                      onTap: () {
                        openFileExplorer();
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }

  _imgFromGallery() async{

    final image = await _picker.getImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    if (image != null) {
      File croppedFile = await _getCroppedFile(image.path);
      if (croppedFile != null) {
        var result = await _getCompressedFile(croppedFile.absolute.path);

        Utils.toast("Please Wait....");

        setState(() {
          imgFile = result;


          if (imgFile != null) {
            base64Image = base64Encode(imgFile.readAsBytesSync());
          }
        });
      }
    }
  }

  _imgFromCamera() async {
    final image = await _picker.getImage(
        source: ImageSource.camera, imageQuality: 50
    );

    if (image != null) {
      File croppedFile = await _getCroppedFile(image.path);
      if (croppedFile != null) {
        var result = await _getCompressedFile(croppedFile.absolute.path);
        Utils.toast("Please wait....");
        setState(() {
          imgFile = result;
          if (imgFile != null) {
            base64Image = base64Encode(imgFile.readAsBytesSync());
          }
        });
      }
    }
  }

  _getCroppedFile(String selectedImagePath) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: selectedImagePath,
        aspectRatioPresets: Platform.isAndroid
        ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
        ]
        : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    return croppedFile;
  }
  _getCompressedFile(String croppedFilePath) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = "${appDocDir.path}/${croppedFilePath.split('/').last}";
    var result = await FlutterImageCompress.compressAndGetFile(
        croppedFilePath, appDocPath,
        quality: 80
    );
    return result;
  }

  _buildFileRenameField() {
    return CustomTextField(
      validator: (value) {
        return Utils.validateField(value);
      },
      onChanged: (value) {
        renamedFile = value;
      },
      labelText: 'Rename File',
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      editable: false,

    );
  }
}


