import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/componenets/logButton.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation color;
  Animation ease;
  Animation easeB;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ease = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    easeB = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    color = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(ease);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: easeB.value * 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  repeatForever: true,
                  displayFullTextOnTap: true,
                  speed: Duration(milliseconds: 750),
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            LogButton(
              logColor: Colors.lightBlueAccent,
              label: 'Log In',
              pressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            LogButton(
              label: 'Register',
              logColor: Colors.blueAccent,
              pressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
