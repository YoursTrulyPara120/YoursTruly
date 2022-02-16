import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/screens/main_feature/select_document.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/custom_text_field.dart';
import 'package:para120/widgets/util.dart';

class NomineeScreen extends StatefulWidget {
  String email, nomineeName, nomineeEmail, nomineePassword, number, selectedRelation, other;

  NomineeScreen({this.email, this.nomineeName, this.nomineeEmail, this.nomineePassword, this.selectedRelation, this.other, this.number});

  @override
  _NomineeScreenState createState() => _NomineeScreenState();
}

class _NomineeScreenState extends State<NomineeScreen> {

  String nomineeName = "", nomineeEmail = "", nomineePassword = "", selectedRelation, other = "";
  TextEditingController _hospitalName = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  var selectedDoctor;

  final ContactPicker _contactPicker = new ContactPicker();
  Contact _contact;
  String filteredContact;

  TextEditingController _contactNumber = new TextEditingController(text: "");
  TextEditingController _nomineeName = new TextEditingController(text: "");
  TextEditingController _nomineeEmail = new TextEditingController(text: "");
  TextEditingController _nomineePassword = new TextEditingController(text: "");
  TextEditingController _other = new TextEditingController(text: "");



  List<String> _accountType = <String>[
    'Mother',
    'Father',
    'Son',
    'Daughter',
    'Grand Mother',
    'Grand Father',
    'Friend',
    'Other',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _nomineeName.text = widget.nomineeName == null ? "" : widget.nomineeName;
      _nomineeEmail.text = widget.nomineeEmail == null ? "" : widget.nomineeEmail;
      _nomineePassword.text = widget.nomineePassword == null ? "" : widget.nomineePassword;
      _contactNumber.text = widget.number == null ? "" : widget.number;
      selectedRelation = widget.selectedRelation == null ? selectedRelation : widget.selectedRelation;
      _other.text = widget.other == null ? "" : widget.other;

      nomineeEmail = widget.nomineeEmail;
      filteredContact = widget.number;
      nomineePassword = widget.nomineePassword;
      other = widget.other;
    });
  }

  void showOtherField(){
    setState(() {
      otherField();
    });
  }

  Widget otherField(){
    return selectedRelation == 'Other' ?
    CustomTextField(
        validator: (value) {
          return Utils.validateField(value);
        },
        onChanged: (value) {
          other = value;
        },
        textSize: 18,
        labelText: 'Other Relation',
        textCapitalization: TextCapitalization.none,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        editable: false,
        input: _other,
    ): Container();
  }

  @override
  Widget build(BuildContext context) {

    print("email is ${widget.email}");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
            'Add Nominee',
            style: GoogleFonts.poppins(
              fontSize: 21.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20,),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: _buildHospitalNameField()
                ),

                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _buildHospitalContactField()
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _buildDaysInHospitalField()
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _buildDaysInICUField()
                ),
                SizedBox(height: 20),
                DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1.1,
                          style: BorderStyle.solid,
                          color: Colors.black38),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9.0, vertical: 3.0),
                      child: DropdownButtonFormField(
                        validator: (value) {
                          selectedRelation = value;
                          if (value == null) {
                            return 'field required';
                          }
                          return null;
                        },
                        items: _accountType
                            .map((value) =>
                            DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.black),
                              ),
                              value: value,
                            ))
                            .toList(),
                        onChanged: (selectedAccountType) {
                          //print('$selectedAccountType');
                          setState(() {
                            selectedRelation = selectedAccountType;
                            print(selectedRelation);
                            showOtherField();
                          });
                        },
                        value: selectedRelation,
                        isExpanded: false,
                        hint: Text(
                          "Relationship With Nominee",
                          style: TextStyle(
                              color: Colors.black, fontSize: 11.0),
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: otherField(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: BtnGradient(
                    top: 100.0,
                    left: 6.0,
                    bottom: 30.0,
                    right: 6.0,
                    onTap: () async {
                      if (_formKey.currentState.validate()) {
                        FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Nominees").doc(nomineeEmail).set({
                          "Name" : _nomineeName.text == null ? nomineeName : _nomineeName.text == "" ? nomineeName :_nomineeName.text,
                          "Number" : filteredContact,
                          "Email" : nomineeEmail,
                          "Password" : nomineePassword,
                          "Relation" : selectedRelation,
                          "Other" : other,
                          "Photos" : [],
                          "Audios" : [],
                          "Videos" : [],
                          "Documents" : [],
                        });

                        FirebaseFirestore.instance.collection("nominees").doc(nomineeEmail).set({
                          "Name" : nomineeName,
                          "Number" : filteredContact,
                          "Email" : nomineeEmail,
                          "Password" : nomineePassword,
                          "Relation" : selectedRelation,
                          "Other" : other,
                        });
                        Navigator.pop(context);
                      }
                    },
                    text: 'Submit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  _buildHospitalNameField() {
    return CustomTextField(

      onChanged: (value) {
        nomineeName = value;
      },
      iconButton: IconButton(onPressed: ()async{
        Contact contact = await _contactPicker.selectContact();
        setState(() {
          _contact = contact;
          _contactNumber.text = _contact.phoneNumber.number;
          _nomineeName.text = _contact.fullName;
          if(_contactNumber.text.contains("+") && _contactNumber.text.contains(" ")){
            print(_contactNumber.text);
            filteredContact = _contactNumber.text.split(" ").join("");
            filteredContact = filteredContact.substring(filteredContact.length - 10);
            print(filteredContact);
          }else if(_contactNumber.text.contains("+")){
            print(_contactNumber.text);
            filteredContact = _contactNumber.text.substring(_contactNumber.text.length - 10);
            print(filteredContact);
          } else if(_contactNumber.text.contains(" ")) {
            print(_contactNumber.text);
            filteredContact = _contactNumber.text.split(" ").join("");
            print(filteredContact);
          }
        });
      }, icon: Icon(Icons.add_circle, color: Colors.indigo,),),
      textSize: 18,
      labelText: 'Nominee Name',
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      editable: false,
      input: _nomineeName,
    );
  }

  _buildHospitalContactField() {
    return CustomTextField(
      validator: (value) {
        if(value.length < 10)
          return 'Please Enter Correct Phone Number';
        else
          return null;
      },
      onChanged: (value) {
        filteredContact = value;

      },
      iconButton: IconButton(onPressed: ()async{
        Contact contact = await _contactPicker.selectContact();
        setState(() {
          _contact = contact;
          _contactNumber.text = _contact.phoneNumber.number;
          _nomineeName.text = _contact.fullName;
          if(_contactNumber.text.contains("+") && _contactNumber.text.contains(" ")){
            print(_contactNumber.text);
            filteredContact = _contactNumber.text.split(" ").join("");
            filteredContact = filteredContact.substring(filteredContact.length - 10);
            print(filteredContact);
          }else if(_contactNumber.text.contains("+")){
            print(_contactNumber.text);
            filteredContact = _contactNumber.text.substring(_contactNumber.text.length - 10);
            print(filteredContact);
          } else if(_contactNumber.text.contains(" ")) {
            print(_contactNumber.text);
            filteredContact = _contactNumber.text.split(" ").join("");
            print(filteredContact);
          }
        });
      }, icon: Icon(Icons.add_circle, color: Colors.indigo,),),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
        LengthLimitingTextInputFormatter(10)
      ],
      labelText: 'Contact Number',
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      editable: false,
      input: _contactNumber,
    );
  }

  _buildDaysInHospitalField() {
    return CustomTextField(
        validator: (value) {
          return Utils.validateEmail(value);
        },
        onChanged: (value) {
          nomineeEmail = value;
        },

        textSize: 18,
        labelText: 'Nominee Email',
        textCapitalization: TextCapitalization.none,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        editable: widget.nomineeEmail == null ? false : true,
        input: _nomineeEmail,
    );
  }
  _buildDaysInICUField() {
    return CustomTextField(
        validator: (value) {
          return Utils.validateField(value);
        },
        onChanged: (value) {
          nomineePassword = value;
        },
        textSize: 18,
        labelText: 'Password',
        textCapitalization: TextCapitalization.none,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.next,
        editable: widget.nomineePassword == null ? false : true,
      input: _nomineePassword,
    );


  }
}
