import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:para120/screens/auth/login_screen.dart';
import 'package:para120/screens/onboarding/slider.dart';
import 'package:permission_handler/permission_handler.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _currentPage = 0;
  PageController _controller = PageController();

  void multiPermission()async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera, Permission.sms, Permission.contacts, Permission.storage,
    ].request();

    if(statuses[Permission.location].isDenied){ //check each permission status after.
      print("Location permission is denied.");
    }

    if(statuses[Permission.camera].isDenied){ //check each permission status after.
      print("Camera permission is denied.");
    }
  }

  List<Widget> _pages = [
    SliderPage(
        title: "Para 120",
        description:
        "Write your secret message that you always wanted to share with your loved one and set the timeline so that we'll send that message to your loved one once you inactive in this app",
        image: "assets/MainFeature.svg"),
    SliderPage(
        title: "SMS Scheduler",
        description:
        "SMS Scheduler is an automated tool which sends the text messages you wrote after a certain period of time with certain frequency. It helps in remembering the important dates and prevents you from forgetting birthdays anniversaries of your near and dear ones. Just write a message and save it.",
        image: "assets/SMSScheduler.svg"),
    SliderPage(
        title: "Digital Locker",
        description:
        "digital locker provides access to authentic virtual documents. It is a digital document wallet where you can store your documents such as driving licence, PAN card, Voter ID, policy documents, etc. You can upload the documents and keep these safe",
        image: "assets/docLocker.svg"),
  ];

  _onchanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: _onchanged,
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (context, int index) {
              return _pages[index];
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_pages.length, (int index) {
                    return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 10,
                        width: (index == _currentPage) ? 30 : 10,
                        margin:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: (index == _currentPage)
                                ? Color(0xff9083e8)
                                : Colors.blue.withOpacity(0.5)));
                  })),
              InkWell(
                onTap: () {
                  if(_currentPage == (_pages.length - 1)){
                    multiPermission();
                    Navigator.push(
                        context, CupertinoPageRoute(builder: (context) => LoginScreen()));
                  }else {
                    _controller.nextPage(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeInOutQuint);
                  }
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  duration: Duration(milliseconds: 300),
                  height: (_currentPage == (_pages.length - 1)) ? 50 : 60,
                  width: (_currentPage == (_pages.length - 1)) ? 170 : 60,
                  decoration: BoxDecoration(
                      color: Color(0xff9083e8),
                      borderRadius: BorderRadius.circular(35)),
                  child: (_currentPage == (_pages.length - 1))
                      ? Text(
                    "Get Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  )
                      : Icon(
                    Icons.navigate_next,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ],
      ),
    );
  }
}