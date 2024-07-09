import 'package:flutter/material.dart';

import '../Login/sign_up.dart';
import '../controller/auth_service.dart';
import '../pages/demo.dart';
import '../pages/login_page.dart';
import '../screen/home.dart';
import '../screen/message.dart';
import '../screen/profile.dart';
import '../screen/search.dart';
import '../screen/upload.dart';


void main() {
  runApp(MaterialApp(home: BottomNavBar(), debugShowCheckedModeBanner: false));
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // title: 'Bottom Navigation Bar Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: BottomNavBar(),
//     );
//   }
// }

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    // Search(),
    SearchScreen(),
    UploadScreen(),
    // ProfileSetupPage(),
    //  SignUpScreen(),
    MessageScreen(),
    ProfileScreen
      (),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(



      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        // Color for the selected item
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            // backgroundColor: Colors.deepOrange,
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Container(
              // padding: EdgeInsets.all(2), // Adjust padding as needed
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 2),
                // Add border
                borderRadius: BorderRadius.circular(10),
                // Add border radius
              ),
              child: Icon(
                Icons.add, // Using built-in plus icon for upload
                size: 30,

              ),
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              size: 30,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Profile',
          ),
        ],
      ),
      extendBody: true, // Ensure the body extends behind the bottom navigation bar
      bottomSheet: Divider(color: Colors.black87), // Divider below the bottom navigation bar

    );
  }
}
