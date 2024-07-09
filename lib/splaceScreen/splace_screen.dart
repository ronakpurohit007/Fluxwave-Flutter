import 'dart:async';

import 'package:flutter/material.dart';

import '../pages/login_page.dart';

class Splace_Screen extends StatefulWidget {
  const Splace_Screen({super.key});

  @override
  State<Splace_Screen> createState() => _Splace_ScreenState();
}

class _Splace_ScreenState extends State<Splace_Screen> {
  @override
  void initState(){
    super.initState();

    Timer(Duration(seconds: 3),
        (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
        }
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child:Padding(
          padding: EdgeInsets.all(78.0),
          child: Image.asset('images/icon.png', width: 700,height: 3000,)
        ),
      ),
    );
  }
}
