//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'package:para120/screens/Home.dart';
// import 'package:para120/screens/Profile.dart';
//
// class PhoneAuth {
//   final String phoneNo;
//   String verificationId;
//   String errorMessage = '';
//   // For firebase auth
//   final auth = FirebaseAuth.instance;
//
//   PhoneAuth({this.phoneNo});
// //
//   Future<void> verifyPhone(BuildContext context) async {
//     final PhoneVerificationCompleted verificationCompleted =
//         (AuthCredential phoneAuthCredential) async {
//       final res = await auth.signInWithCredential(phoneAuthCredential);
//       // Todo After Verification Complete
//       Navigator.push(
//           context, CupertinoPageRoute(builder: (context) => ProfileScreen(mobileNumber: phoneNo,)));
//         };
// //
//     final PhoneVerificationFailed verificationFailed =
//         (FirebaseAuthException authException) {
//       print('Auth Exception is ${authException.message}');
//     };
// //
//     final PhoneCodeSent codeSent =
//         (String verificationId, [int forceResendingToken]) async {
//       print('verification id is $verificationId');
//       this.verificationId = verificationId;
//     };
// //
//     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
//         (String verificationId) {
//       this.verificationId = verificationId;
//     };
// //
//     await auth.verifyPhoneNumber(
//       // mobile no. with country code
//       phoneNumber: phoneNo,
//       timeout: const Duration(seconds: 30),
//       verificationCompleted: verificationCompleted,
//       verificationFailed: verificationFailed,
//       codeSent: codeSent,
//       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
//     );
//   }
//
//   signIn(context,{@required String smsOTP}) {
//     try {
//       final AuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsOTP,
//       );
//       auth.signInWithCredential(credential);
//       // Todo After Verification Complete
//       Navigator.push(
//           context, CupertinoPageRoute(builder: (context) => ProfileScreen(mobileNumber: phoneNo, loginType: 'otp',)));
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void signout() {
//     auth.signOut();
//   }
// }
//
//
//
