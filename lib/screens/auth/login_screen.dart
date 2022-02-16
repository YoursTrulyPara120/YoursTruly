import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:para120/screens/auth/Profile.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/custom_text_field.dart';
import 'package:para120/widgets/util.dart';
import 'package:para120/widgets/widgets.dart';
import 'package:sizer/sizer.dart';

import '../main_feature/Home.dart';
import 'otp_confirmation_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNo;

  final auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  FacebookLogin _facebookLogin = FacebookLogin();

  void googleSignInMethod() async{
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print(googleUser.displayName);
    print(googleUser.email);
    print(googleUser.photoUrl);
    GoogleSignInAuthentication googleSignInAuthentication = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    await auth.signInWithCredential(credential).then((user){
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => ProfileScreen(name: googleUser.displayName, email: googleUser.email, profileUrl: googleUser.photoUrl, loginType: 'social',)));
    });

  }


  void facebookSignInMethod()async{
    FacebookLoginResult result = await _facebookLogin.logIn(['email']);
    print(result);

    final accessToken = result.accessToken.token;

    if(result.status == FacebookLoginStatus.loggedIn){
      final faceCredential = FacebookAuthProvider.credential(accessToken);

      await auth.signInWithCredential(faceCredential).then((user) async{
        print(user.user.displayName);
        print(user.user.email);
        print(user.user.photoURL);
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => ProfileScreen(name: user.user.displayName, email: user.user.email, profileUrl: user.user.photoURL, loginType: 'social',)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text("Sign In",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 22.0),
                        textAlign: TextAlign.center)),
                Container(
                    padding: EdgeInsets.only(top: 20),
                    child: _buildMobileField()),
                SizedBox(
                  height: 24,
                ),
                BtnGradient(
                  onTap: () {
                    _hideKeyboard(context);
                    if (_formKey.currentState.validate()) {
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (BuildContext context) =>
                              OTPConfirmationPage(phoneNo: phoneNo)));
                    }
                  },
                  text: "Send OTP",
                  top: 28, left: 28, bottom: 28, right: 28,
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SvgPicture.asset("assets/login_or.svg")
                ),
                SignInButton(
                  Buttons.Google,
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  text: "Login with Google",
                  onPressed: () async {
                    _showProgressDialog(context);
                    try{
                      googleSignInMethod();
                    }catch(e){
                      Navigator.pop(context);
                      Utils.toast('Google Sign In Failed. Please try again');
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                SignInButton(
                  Buttons.Facebook,
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  text: "Login with Facebook",
                  onPressed: () async {
                    _showProgressDialog(context);
                    try{
                      facebookSignInMethod();
                      Navigator.pop(context);
                    }catch(e){
                      Navigator.pop(context);
                      Utils.toast('Facebook Sign In Failed. Please try again');
                    }

                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
          phoneNo = "+91 $value";
        },
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.none,
        labelText: 'Mobile Number',
        editable: false);
  }

  _hideKeyboard(BuildContext context){
    FocusScope.of(context).unfocus();
  }

  _showProgressDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      content: new Row(
          children: [
            CircularProgressIndicator(),
            Container(margin: EdgeInsets.only(left: 8),child:Text("Loading..." )),
          ]),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
}
