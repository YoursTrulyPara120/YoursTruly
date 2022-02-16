import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

InputDecoration textDecoration(String label) {
  return InputDecoration(
      isDense: true,
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(50))),

      border:  OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(50))
      ),

      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(50))),

      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(50))),

      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(50))),
      labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14.0),
      errorStyle: TextStyle(
          color: Colors.red,fontSize: 13.0
      ),
      labelText: label
  );
}