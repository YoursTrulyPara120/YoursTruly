import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Utils {
  static toast(String text) {
    return Fluttertoast.showToast(msg: text,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static flushbar(BuildContext context, String title, String message) {
    return Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 2),
    ).show(context);
  }

  static MemoryImage imageFromBase64String(String base64String) {
    return MemoryImage(base64.decode(base64.normalize(base64String)));
  }
  static Color getPrimaryColor(){
    return Color(0xff9083e8);
  }
  static Color getPrimaryDarkColor(){
    return Color(0xff634ee8);
  }
  
  static Text getPreviewTextTitle(String text){
    return Text(text, style: GoogleFonts.poppins(
        fontSize: 16.0, color: const Color(0xff000000), fontWeight: FontWeight.w500)
    );
  }
  static Text getPreviewTextDetail(String text){
    return Text(text, style: GoogleFonts.poppins(
        fontSize: 14.0, color: const Color(0xff000000), fontWeight: FontWeight.normal)
    );
  }

  static Widget getUploadWidget(){

    return Container(
        padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
        decoration: BoxDecoration(
            color: getPrimaryColor(),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          children: [
            SvgPicture.asset('assets/upload.svg', fit: BoxFit.none),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Upload Document',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400, fontSize: 16.0, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
    );
  }
  
  static String getRelationshipId(String relation){
    String id = relation;
    if (relation == 'Self') {
      id = "1";
    } else if (relation == 'Spouse') {
      id = "2";
    } else if (relation == 'Child') {
      id = "3";
    } else if (relation == 'Father') {
      id = "4";
    } else if (relation == 'Mother') {
      id = "5";
    } else if (relation == 'Grand Father') {
      id = "6";
    } else if (relation == 'Grand Mother') {
      id = "7";
    } else if (relation == 'Father-in-law') {
      id = "8";
    } else if (relation == 'Mother-in-law') {
      id = "9";
    } else if (relation == 'Brother') {
      id = "10";
    } else if (relation == 'Sister') {
      id = "11";
    }
    return id;
  }
  static String getRelationshipFromId(String relationId){
    String relation = "Self";
    switch(relationId){
      case "1":
        relation = "Self";
        break;
      case "2":
        relation = "Spouse";
        break;
      case "3":
        relation = "Child";
        break;
      case "4":
        relation = "Father";
        break;
      case "5":
        relation = "Mother";
        break;
      case "6":
        relation = "Grand Father";
        break;
      case "7":
        relation = "Grand Mother";
        break;
      case "8":
        relation = "Father-in-Law";
        break;
      case "9":
        relation = "Mother-in-Law";
        break;
      case "10":
        relation = "Brother";
        break;
      case "11":
        relation = "Sister";
        break;
    }
    return relation;
  }
  static String dateConverter(String date) {
    final format = DateFormat("dd-MM-yyyy");
    DateTime gettingDate = format.parse(date);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(gettingDate);
    return formatted;
  }
  static DateTime convertToDate(String date) {
    final format = DateFormat("dd-MM-yyyy");
    DateTime gettingDate = format.parse(date);
    return gettingDate;
  }
  static validateEmail(String value) {
    if (value.isEmpty || value == null) {
      return "field required";
    }
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
        r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]'
        r'+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'invalid email';
  }
  static validateField(String value) {
    if (value.isEmpty || value == null) {
      return "field required";
    }
    return null;
  }
  static validatePhone(String value) {
    if (value.isEmpty || value == null) {
      return "field required";
    } else if (value.length < 10){
      return 'invalid mobile no';
    }
    return null;
  }
  static validateStartDate(DateTime value) {
    if (value == null) {
      return "Please select policy start date";
    }
    return null;
  }
  static validateEndDate(DateTime value, String dateStart) {
    if (value == null) {
      return 'Please select policy end date';
    } else {
      var startDate = Utils.convertToDate(dateStart);
      if (value.isBefore(startDate)) {
        return 'End Date cannot be before Start Date';
      } else if (value.isAtSameMomentAs(startDate)){
        return 'End Date cannot be same as Start Date';
      }
    }
    return null;
  }

  static validateDate(DateTime value) {
    if (value == null) {
      return "Please select date";
    }
    return null;
  }
  static validateTime(DateTime value) {
    if (value == null) {
      return "Please select time";
    }
    return null;
  }
}