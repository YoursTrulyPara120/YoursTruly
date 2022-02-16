
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/widgets/util.dart';
import 'package:sizer/sizer.dart';

class BtnGradient extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool isLoading;
  final double top, bottom, left, right;
  BtnGradient({this.text, this.onTap, this.isLoading, this.top, this.left, this.right, this.bottom}) ;

  @override
  Widget build(BuildContext context) {
    bool _isLoading = isLoading ?? false;


    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.0,
        margin: EdgeInsets.only(
            top: top, left: left, bottom: bottom, right: right),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors : [Color(0xff9083e8), Color(0xff9083e8)],
              begin: FractionalOffset.centerLeft,
              end: FractionalOffset.centerRight,
            ),
            borderRadius: BorderRadius.circular(40)),
        child: Stack(
          children: [
            Visibility(
              visible: _isLoading ? false : true,
              child: Center(
                child: Text(
                  text ?? "Text",
                  style: GoogleFonts.poppins(color: Colors.white,fontSize: 14.0),
                    textAlign: TextAlign.center),
                ),
              ),
            Visibility(
              visible: _isLoading,
              child: Center(
                child: SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: CircularProgressIndicator(color: Colors.white,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//style: GoogleFonts.poppins(color: Colors.white,fontSize: 14.0.sp),
//             textAlign: TextAlign.center),
//         onPressed: onTap,