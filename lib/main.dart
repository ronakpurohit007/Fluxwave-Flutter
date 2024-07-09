import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:phone_number/controller/auth_service.dart';

import 'package:phone_number/pages/login_page.dart';
import 'package:phone_number/splaceScreen/splace_screen.dart';

import 'firebase_options.dart';
import 'home/navigation_bar.dart';

//



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fluxvawe',
      home: CheckUserLoggedInorNot());
 
  }
}


class CheckUserLoggedInorNot extends StatefulWidget {
  const CheckUserLoggedInorNot({super.key});

  @override
  State<CheckUserLoggedInorNot> createState() => _CheckUserLoggedInorNotState();
}

class _CheckUserLoggedInorNotState extends State<CheckUserLoggedInorNot> {
  @override
  void initState() {
    AuthService.isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Splace_Screen()),
        );
      }
    });


    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

