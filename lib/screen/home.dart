import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../friends/profile_screen_demo.dart';
import '../friends/request_show.dart';
import '../pages/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(left: 1),
            child: Image.asset(
              'images/name_logo1.png',
              width: 150,
              height: 150,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  FriendRequestsScreen(),
                        ));
                  },
                  iconSize: 30,
                  color: Colors.black,
                  tooltip: 'Request',
                  icon: Icon(Icons.person_add_alt_1_rounded)),
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10.0),
            // Adjust the height of the divider
            child: SizedBox(
              height: 10.0,
              child: Divider(color: Colors.grey),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: (){
                // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(),));
              }, child: Text("Demo Profile"))
            ],
          ),
        ),
      ),
    );
  }
}
