import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_service.dart';
import '../home/navigation_bar.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;

  const SignUpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  void selectImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path).readAsBytesSync();
      });
    }
  }


  void saveProfile() async {
    String name = nameController.text.trim();
    String username = usernameController.text.trim();
    String about = aboutController.text.trim();
    String phone = widget.phoneNumber;

    if (_image == null || name.isEmpty || username.isEmpty || about.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields and select an image");
      return;
    }

    bool userExists = await AuthService.checkUserExists();

    if (userExists) {
      Fluttertoast.showToast(msg: "User already exists with this phone number");
      return;
    }

    String? uid = AuthService.getCurrentUserUID();

    if (uid == null) {
      Fluttertoast.showToast(msg: "User is not logged in");
      return;
    }

    try {
      String imageUrl = await uploadImageToStorage('profileImage.jpg', _image!);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'username': username,
        'about': about,
        'phone': phone,
        'imageUrl': imageUrl,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profileSetupComplete', true);

      Fluttertoast.showToast(msg: "Profile created successfully");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );

    } catch (err) {
      Fluttertoast.showToast(msg: "Failed to save user data: $err");
    }
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    try {
      img.Image? image = img.decodeImage(file);
      Uint8List jpegData = Uint8List.fromList(img.encodeJpg(image!));

      Reference ref = _storage.ref().child(childName);
      UploadTask uploadTask = ref.putData(jpegData);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: selectImage,
              child: _image != null
                  ? CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(_image!),
              )
                  : CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                    "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: aboutController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: "About",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
