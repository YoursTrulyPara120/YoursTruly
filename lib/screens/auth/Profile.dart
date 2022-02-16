
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:para120/screens/auth/otp_confirmation_screen.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/custom_text_field.dart';
import 'package:para120/widgets/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_feature/Home.dart';
import '../bottom_navigation.dart';
import '../fullscreen_img.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {

  String name;
  String email;
  String profileUrl;
  String mobileNumber;
  String loginType;
  String myProfile;

  ProfileScreen({this.name, this.email, this.profileUrl, this.mobileNumber, this.loginType, this.myProfile});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final storage = FirebaseStorage.instance;

  File imageFile;
  final _picker = ImagePicker();
  Future<Image> profileImage;
  var isSocialLogin = false;
  String firstName;
  String lastName;
  String email;
  String mobileNumber;
  String profilePic;
  bool _loginFormLoading = false;

  TextEditingController _firstName = TextEditingController(text: "");
  TextEditingController _lastName = TextEditingController(text: "");
  TextEditingController _email = TextEditingController(text: "");
  TextEditingController _mobileNumber = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();

    widget.loginType == 'social' ? _firstName.text = widget.name.split(" ")[0] : _firstName.text;
    widget.loginType == 'social' ? _lastName.text = widget.name.split(" ")[1] : _lastName.text;
    _email.text = widget.email;
    _mobileNumber.text = widget.mobileNumber;
    profilePic = widget.profileUrl;
    email = widget.email;
    mobileNumber = widget.mobileNumber;
    widget.myProfile == "Profile" ? getProfile(): null;

  }

  saveEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              leading: widget.myProfile == null ? Padding(
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
              ): Container(),
              title: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    showImage(),
                    // widget.loginType == "profile" ? updateImage() : showImage(),
                    Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: _buildFirstNameField()),
                    Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: _buildLastNameField()),
                    Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: _buildEmailField()),
                    Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: _buildMobileField()),
                    Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: BtnGradient(
                        top: 0, left: 28, bottom: 28, right: 28,
                        isLoading: _loginFormLoading,
                        onTap: () async {
                          _hideKeyboard(context);

                          if (_formKey.currentState.validate()) {
                            await updateProfile();
                            if (widget.loginType == 'social') {
                              Navigator.pushReplacement(
                                  context, CupertinoPageRoute(
                                  builder: (context) => OTPConfirmationPage(phoneNo: '+91 $mobileNumber', loginType: widget.loginType, email: email,)));
                            } else{
                              Navigator.pushReplacement(
                                  context, CupertinoPageRoute(
                                  builder: (context) => BottomNavigation()));
                            }
                          }

                          // await FirebaseAuth.instance.signOut();
                          // Navigator.push(
                          //     context, CupertinoPageRoute(builder: (context) => LoginScreen()));

                        },
                        text: widget.myProfile == "Profile" ? "Update" : 'Submit'
                      ),
                    ),
                    widget.myProfile == 'Profile' ? Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: BtnGradient(
                          top: 0, left: 28, bottom: 28, right: 28,
                          onTap: () async {
                            Navigator.push(
                                context, CupertinoPageRoute(builder: (context) => LoginScreen()));
                            await FirebaseAuth.instance.signOut();
                          },
                          text: 'Log Out'
                      ),
                    ) : Container(),

                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  Future updateProfile() async{

    saveEmail();

    setState(() {
      _loginFormLoading = true;
    });

    var snapshot = storage.ref().child('email/profile pic/pic');
    if(imageFile != null){await snapshot.putFile(imageFile);
    profilePic = await snapshot.getDownloadURL();} else{
      print('no image selected');
    }

    CollectionReference users =
    FirebaseFirestore.instance.collection('users');
    users.doc(email).set({
      'First_Name': firstName,
      'Last_Name':lastName,
      'Email': email,
      'Mobile_Number':mobileNumber,
      "Date":DateTime.now(),
      "profile_pic": profilePic,
    }).then(
          (value) {
        setState(() {
          _loginFormLoading = false;
        });

      },
    ).catchError((error) => print("Failed to add user: $error"));

  }

  void getProfile() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.email).get();
    Map<String,dynamic> userdata = snapshot.data();

    setState(() {
      firstName = userdata['First_Name'];
      lastName = userdata['Last_Name'];
      email = userdata['Email'];
      mobileNumber = userdata['Mobile_Number'];
      profilePic = userdata['profile_pic'];

      _firstName.text = firstName;
      _lastName.text = lastName;
      _email.text = email;
      _mobileNumber.text = mobileNumber;
    });


  }

  Widget _buildFirstNameField() {
    return CustomTextField(
        validator: (value) {
          firstName = value;
          if (value.isEmpty) {
            return 'field required';
          }
          return null;
        },
        onChanged: (value) {
          firstName = value;
        },
        input: _firstName,
        textInputAction: TextInputAction.next,
        labelText: "First Name",
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.name,
        textSize: 14.0,
        editable: false
    );
  }

  Widget _buildLastNameField() {
    return CustomTextField(
        validator: (value) {
          lastName = value;
          if (value.isEmpty) {
            return 'field required';
          }
          return null;
        },
        onChanged: (value) {
          lastName = value;
        },
        textInputAction: TextInputAction.next,
        labelText: "Last Name",
        input: _lastName,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.name,
        textSize: 14.0,
        editable: false
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      validator: (value){
        email = value;
        return Utils.validateEmail(email);
      },
      onChanged: (value) {
        email = value;
      },
      enabled: widget.loginType == 'social' || widget.myProfile == "Profile" ? false : true,
      labelText: 'Email ID',
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.emailAddress,
      input: _email,
      textSize: 15.0,
      editable: false,
    );
  }

  Widget _buildMobileField() {
    return CustomTextField(
      validator: (value) {
        if (value.length < 10 || value.length > 10) {
          return 'Please Enter Valid Mobile Number';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        mobileNumber = value;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        LengthLimitingTextInputFormatter(10)
      ],
      labelText: 'Mobile Number',
      enabled: widget.loginType == 'social' ? true : false,
      editable: false,
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textSize: 14.0,
      input: _mobileNumber,
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
                      leading: new Icon(Icons.view_carousel_outlined),
                      title: new Text('View Image'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context, new CupertinoPageRoute(builder: (context) => FullScreenImg(img: profilePic)));
                      }),
                ],
              ),
            ),
          );
        });
  }
  _imgFromGallery() async {
    var image = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        imageFile = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }
  _imgFromCamera() async {
    var image = await _picker.getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if (image != null) {
        imageFile = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }



  Widget showImage() {

    return GestureDetector(
      onTap: () => _showPicker(context),
      child:  imageFile != null ?
      Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xff9083e8),
                  child: CircleAvatar(
                    radius: 53,
                    backgroundColor: Colors.white,
                    backgroundImage: FileImage(imageFile),
                  ),
                )),
            Positioned(bottom: 0,
                right: 0,
                left: 0,
                height: 35,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xff9083e8),
                    child: Icon(
                      Icons.add_a_photo, color: Colors.white,
                      size: 16,)

                ))
          ],
        ),
      )   : profilePic != null ? Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  radius: 55,
                  // backgroundColor: Color(0xfff65a15),
                  // backgroundImage: NetworkImage(profilePic),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55),
                    child: CachedNetworkImage(
                      imageUrl: profilePic,
                      fit: BoxFit.cover,
                      height: 110,
                      width: 110,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.white,)),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),

                )),
            Positioned(bottom: 0,
                right: 0,
                left: 0,
                height: 35,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xff9083e8),
                    child: Icon(
                      Icons.add_a_photo, color: Colors.white,
                      size: 16,)
                ))
          ],
        ),
      ) :profilePic == null ?  Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xff9083e8),

                  child: CircleAvatar(
                    radius: 53,
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/drawer_profile.svg', height: 30, width: 30,fit: BoxFit.cover,),

                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(bottom: 0,
                right: 0,
                left: 0,
                height: 35,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xff9083e8),
                    child: Icon(
                      Icons.add_a_photo, color: Colors.white,
                      size: 16,)
                ))
          ],
        ),
      ) : Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xff9083e8),

                  child: CircleAvatar(
                    radius: 53,
                    backgroundColor: Colors.white,
                    child: Container(
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30,),
                          SvgPicture.asset('assets/drawer_profile.svg', height: 30, width: 30,fit: BoxFit.cover, color: Color(0xff9083e8),),

                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(bottom: 0,
                right: 0,
                left: 0,
                height: 35,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xff9083e8),
                    child: Icon(
                      Icons.add_a_photo, color: Colors.white,
                      size: 16,)
                ))
          ],
        ),
      ),
    );

  }

  _hideKeyboard(BuildContext context){
    FocusScope.of(context).unfocus();
  }
}
