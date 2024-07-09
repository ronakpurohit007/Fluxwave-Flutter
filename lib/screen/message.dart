import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Message",style: TextStyle(fontSize: 30,fontFamily:'Open Sans',fontWeight: FontWeight.w700),),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0), // Adjust the height of the divider
          child: SizedBox(
            height: 15.0,
            child: Divider(color: Colors.grey),
          ),
        ),
      ),
    body: Center(
    child: Text("Message Screen"),)
    );
  }
}
