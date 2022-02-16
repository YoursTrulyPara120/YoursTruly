import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:para120/widgets/btn_gradient.dart';
import 'package:para120/widgets/custom_text_field.dart';
import 'package:para120/widgets/input_style.dart';
import 'package:para120/widgets/util.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:telephony/telephony.dart' as smsSender;


class MsgScheduler extends StatefulWidget {

  String email;
  MsgScheduler({this.email});


  @override
  _MsgSchedulerState createState() => _MsgSchedulerState();
}

class _MsgSchedulerState extends State<MsgScheduler> {

  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateTime date;
  final displayTimeFormat = DateFormat("HH:mm");
  TimeOfDay timeFormat;
  var dateFormat;

  TextEditingController _name = TextEditingController(text: "");
  TextEditingController _selectedDate = TextEditingController(text: "");
  TextEditingController _selectedTime = new TextEditingController(text: "");
  TextEditingController _contactNumber = new TextEditingController(text: "");

  String contactNumber;
  int delay;
  String number;

  final ContactPicker _contactPicker = new ContactPicker();
  Contact _contact;
  String filteredContact;
  String message;
  String name;
  DateTime tempDate;
  final smsSender.Telephony telephony = smsSender.Telephony.instance;
  String msgId;


  Future<void> _selectDate(BuildContext context) async {

    final now = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date ?? now,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null && picked != date) {
      print('hello $picked');
      setState(() {
        date = picked;
      });
    }
  }


  Future<void> scheduleSMS() async {
    // Load persisted fetch events from SharedPreferences
    // Configure BackgroundFetch.
    String to;
    String message;
    try {
      var status = await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
      ), (String taskId) async{
        print("$msgId, $delay, $filteredContact, $message");
        print("[BackgroundFetch] taskId: $taskId");
        switch (taskId) {
          case 'flutter_background_fetch':
            QuerySnapshot querySnapshot = await FirebaseFirestore
                .instance
                .collection("users").doc(widget.email).collection("Nominees")
                .get();

            if(querySnapshot.docs.isNotEmpty) {
              for (int i = 0; i < querySnapshot.docs.length; i++) {
                var a = querySnapshot.docs[i];
                if (a.get('Scheduled_At').toDate().isBefore(DateTime.now()) &&
                    a.get('status') == "running") {
                  print("if running");
                  telephony.sendSms(to: a.get('Number'), message: a.get('Message'));
                  await FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Nominees").doc(a.id).update({
                    "status": "sent",
                  });
                } else {
                  print("do nothing");
                }
              }
            }
            QuerySnapshot querySnapshot2 = await FirebaseFirestore
                .instance
                .collection("users").doc(widget.email).collection("Scheduled_Messages")
                .get();

            if (querySnapshot2.docs.isNotEmpty) {
              for (int i = 0; i < querySnapshot2.docs.length; i++) {
                var a = querySnapshot2.docs[i];
                if (a.get('DateTime').toDate().isBefore(DateTime.now()) && a.get('status') == "running") {
                  print("if running");
                  telephony.sendSms(to: a.get('Number'), message: a.get('Message'));
                  await FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Scheduled_Messages").doc(a.id).update({
                    "status": "sent",
                  });
                } else {
                  print("do nothing");
                }
              }
            } else {
              print("do nothing");
            }
            break;
          default:
            await FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Scheduled_Messages").doc(taskId).get().then((doc){
              to = doc.data()['Number'];
              message = doc.data()['Message'];
            });
            await telephony.sendSms(to: to, message: message);
            await FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Scheduled_Messages").doc(taskId).update({
              "status" : "sent",
            });
            break;
        }
        BackgroundFetch.finish(taskId);
      }, _onBackgroundFetchTimeout);
      print('[BackgroundFetch] configure success: $status');

      BackgroundFetch.scheduleTask(TaskConfig(
        taskId: msgId,
        delay: int.tryParse("${delay}000"),
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
      ));
    } catch(e) {
      print("[BackgroundFetch] configure ERROR: $e");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }


  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }




  @override
  Widget build(BuildContext context) {

    print("email is ${widget.email}");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
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
              'SMS Scheduler',
              style: GoogleFonts.poppins(
                fontSize: 21.0,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _buildNameField()
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _buildHospitalContactField()
                ),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: _buildSelectDateField()
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: DateTimeField(
                    validator: (value) {
                      return Utils.validateTime(value);
                    },
                    style: GoogleFonts.poppins(fontSize: 16.0),
                    decoration: textDecoration('Select Time'),
                    onShowPicker: (context, currentValue) async{
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                      );
                      tempDate = displayTimeFormat.parse(
                          time.hour.toString() +
                              ":" + time.minute.toString());
                      dateFormat = DateFormat("h:mm a"); // you can change the format here
                      print(dateFormat.format(tempDate));
                      print(_selectedTime.text);
                      return DateTimeField.convert(time);


                    },
                    controller: _selectedTime,
                    format: displayTimeFormat,


                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: _buildMessageField()
                ),








                // Padding(
                //     padding: EdgeInsets.only(top: 20.0),
                //     child: _buildDaysInHospitalField()
                // ),
                // Padding(
                //     padding: EdgeInsets.only(top: 20.0),
                //     child: _buildDaysInICUField()
                // ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: BtnGradient(
                    top: 60.0,
                    left: 6.0,
                    bottom: 2.0,
                    right: 6.0,
                    onTap: () async {
                      BackgroundFetch.finish("flutter_background_fetch");
                      print(_selectedDate.text);
                      print(_selectedTime.text);
                      msgId = randomAlpha(10);

                      final birthday = DateTime(
                          int.tryParse(_selectedDate.text.split("/")[2]),
                          int.tryParse(_selectedDate.text.split("/")[1]),
                          int.tryParse(_selectedDate.text.split("/")[0]),
                          int.tryParse(_selectedTime.text.split(":")[0]),
                          int.tryParse(_selectedTime.text.split(":")[1].split(" ")[0]));
                      //final birthday = DateTime(2021, 08, 23, 02, 43);
                      final date2 = DateTime.now();
                      delay = birthday.difference(date2).inSeconds;
                      print(delay);

                      FirebaseFirestore.instance.collection("users").doc(widget.email).collection("Scheduled_Messages").doc(msgId).set({
                        "MsgId" : msgId,
                        "Name" : name == null ? _name.text : name,
                        "Number" : filteredContact,
                        "Date" : _selectedDate.text,
                        "Time" : (dateFormat.format(tempDate)).toString(),
                        "Message" : message,
                        "status" : "running",
                        "DateTime" : birthday,
                      });
                      scheduleSMS();
                      Navigator.pop(context);

                    },
                    text: 'Submit',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }



  _buildNameField() {
    return CustomTextField(
      validator: (value) {
        return Utils.validateField(value);
      },
      onChanged: (value) {
        setState(() {
          name = value;
        });
      },
      iconButton: IconButton(onPressed: ()async{
        Contact contact = await _contactPicker.selectContact();
        setState(() {
          _contact = contact;
          _contactNumber.text = _contact.phoneNumber.number;
          _name.text = _contact.fullName;
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
      labelText: 'Name',
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      editable: false,
      input: _name,
    );
  }

  _buildSelectDateField() {
    return CustomTextField(
      validator: (value) {
        return Utils.validateField(value);
      },
      onTap: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        await _selectDate(context);
        _selectedDate.text = DateFormat('dd/MM/yyyy').format(date);
        },
      labelText: 'Select Date',
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      editable: false,
      input: _selectedDate,
      onEditingComplete: (){
        FocusScope.of(context).nextFocus();
      },
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
            _name.text = _contact.fullName;
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
        textInputAction: TextInputAction.done,
        editable: false,
        input: _contactNumber,
    );
  }

  _buildMessageField() {
    return CustomTextField(
      validator: (value) {
        return Utils.validateField(value);
      },
      onChanged: (value) {
        setState(() {
          message = value;
        });

      },
      labelText: 'Your Message',
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      maxLines: 5,
      borderRadius: 10,
      editable: false,
    );
  }
}
