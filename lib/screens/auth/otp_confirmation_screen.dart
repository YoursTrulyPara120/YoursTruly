
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/main_feature/Home.dart';
import 'package:para120/services/phone_auth.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/pin_code_text_field.dart';
import 'package:para120/widgets/widgets.dart';
import 'package:sizer/sizer.dart';

import 'Profile.dart';
import '../bottom_navigation.dart';

class OTPConfirmationPage extends StatefulWidget {

  final String phoneNo;
  String loginType;
  String email;

  OTPConfirmationPage({Key key, this.phoneNo, this.loginType, this.email}) : super(key: key);

  @override
  _OTPConfirmationPageState createState() => _OTPConfirmationPageState();
}

class _OTPConfirmationPageState extends State<OTPConfirmationPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _otp;
  String phoneNo;
  //PhoneAuth phoneAuth;

  bool _loginFormLoading = false;



  @override
  void initState() {
    super.initState();
    phoneNo = widget.phoneNo;
    // phoneAuth = PhoneAuth(phoneNo: widget.phoneNo);
    verifyPhone(context);
  }

  String numberCountValidator(value, int requiredCount) {
    if (value.length < requiredCount || value.length > requiredCount) {
      return "Invalid";
    } else {
      _formKey.currentState.save();
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Color(0xff9083e8));
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(29.0),
                  bottomLeft: Radius.circular(29.0),
                ),
                gradient: LinearGradient(
                  colors: [const Color(0xff9083e8), Color(0xff9083e8)],
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, 1.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 12.0,
                    left: 12.0,
                  ),
                  child: Container(
                    height: 500.0,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            children: [
                              Container(margin: EdgeInsets.only(top: 20.0),
                                child: Container(height: 80.0, width: 80.0,
                                  child: SvgPicture.asset("assets/otp_mail.svg", allowDrawingOutsideViewBox: true,),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text('Verification Code', style: GoogleFonts.poppins(fontSize: 20.0, color: const Color(0xff000000),
                                fontWeight: FontWeight.w600,), textAlign: TextAlign.left),
                              SizedBox(height: 20),
                              Text('Please enter the verification code\nsent on $phoneNo',
                                  style: GoogleFonts.poppins(fontSize: 12.0, color: const Color(0xcc000000),),
                                  textAlign: TextAlign.center),
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: PinCodeTextField(
                                  autofocus: true,
                                  highlight: true,
                                  highlightColor: Colors.blue,
                                  defaultBorderColor: Colors.black26,
                                  hasTextBorderColor: Color(0xfff67018),
                                  pinBoxBorderWidth: 1.0,
                                  maxLength: 6,
                                  onTextChanged: (text) {

                                  },
                                  onDone: (text) {
                                    _otp = text;
                                    _hideKeyboard(context);
                                  },
                                  pinBoxWidth: 40,
                                  pinBoxHeight: 55,
                                  wrapAlignment: WrapAlignment.spaceAround,
                                  pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                                  pinBoxRadius: 8,
                                  pinTextStyle: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600),
                                  pinTextAnimatedSwitcherTransition:
                                  ProvidedPinBoxTextAnimation.scalingTransition,
                                  pinTextAnimatedSwitcherDuration:
                                  Duration(milliseconds: 100),
                                  highlightAnimationBeginColor: Colors.black,
                                  highlightAnimationEndColor: Colors.white12,
                                  keyboardType: TextInputType.number,
                                ),
                              ),

                              // Resend OTP Button
                              Row(
                                children: [
                                  Expanded(
                                    child: BtnGradient(
                                      text: "Verify OTP",
                                      top: 28, left: 28, bottom: 28, right: 28,

                                      onTap: () {
                                        _hideKeyboard(context);
                                        setState(() {
                                          _loginFormLoading = true;
                                        });
                                        signIn(context,smsOTP: _otp);

                                      },
                                      isLoading: _loginFormLoading,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // body: Form(
      //   key: _formKey,
      //   child: Container(
      //     margin: EdgeInsets.symmetric(horizontal: 24),
      //     child: Column(
      //       children: [
      //         Spacer(),
      //         Text('Verify the otp sent to this number', style: TextStyle(fontSize: 22),),
      //         SizedBox(height: 24,),
      //         Text(widget.phoneNo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
      //         SizedBox(height: 30,),
      //         TextFormField(
      //             validator: (value) => numberCountValidator(value, 6),
      //           keyboardType: TextInputType.number,
      //           decoration: InputDecoration(
      //               hintText: "Your OTP here"
      //           ),
      //           onChanged: (val){
      //             _otp = val;
      //           },),
      //         SizedBox(height: 24,),
      //         GestureDetector(
      //           onTap: () async {
      //             if(_formKey.currentState.validate()){
      //               signIn(context,smsOTP: _otp);
      //             }
      //           },
      //           child: blueButton(context: context, label : "Proceed")
      //         ),
      //         SizedBox(height: 250,),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  String verificationId;
  String errorMessage = '';
  // For firebase auth
  final auth = FirebaseAuth.instance;

//
  Future<void> verifyPhone(BuildContext context) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
          final res = await auth.signInWithCredential(phoneAuthCredential);
          // Todo After Verification Complete
          if (widget.loginType == 'social') {
            Navigator.pushReplacement(
                context, CupertinoPageRoute(builder: (context) => BottomNavigation()));
          }else{
            Navigator.pushReplacement(
                context, CupertinoPageRoute(builder: (context) =>
                ProfileScreen(mobileNumber: phoneNo.split(" ")[1], )));
          }
        };
//
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print('Auth Exception is ${authException.message}');
    };
//
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('verification id is $verificationId');
      this.verificationId = verificationId;
    };
//
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
    };
//
    await auth.verifyPhoneNumber(
      // mobile no. with country code
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 30),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  signIn(context,{@required String smsOTP})async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final UserCredential authResult = await auth.signInWithCredential(credential).catchError((onError){
        setState(() {
          _loginFormLoading = false;
        });
        _alertDialogBuilder("Invalid OTP");
      });



      // Todo After Verification Complete
      if(authResult != null){
        if (widget.loginType == 'social') {
          Navigator.pushReplacement(
              context, CupertinoPageRoute(builder: (context) => BottomNavigation()));
        }else{
          Navigator.pushReplacement(
              context, CupertinoPageRoute(builder: (context) =>
              ProfileScreen(mobileNumber: phoneNo.split(" ")[1])));
        }
      }

    } catch (e) {

      print(e);
    }
  }

  void signout() {
    auth.signOut();
  }

  _hideKeyboard(BuildContext context){
    FocusScope.of(context).unfocus();
  }

  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Container(
              child: Text(error),
            ),
            actions: [
              FlatButton(
                child: Text("Close Dialog"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }
}
