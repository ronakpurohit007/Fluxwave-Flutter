import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controller/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      String? uid = AuthService.getCurrentUserUID();

      if (uid != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (snapshot.exists) {
          setState(() {
            _fullNameController.text = snapshot.get('name');
            _usernameController.text = snapshot.get('username');
            _aboutController.text = snapshot.get('about');
            _phoneController.text = snapshot.get('phone');
            _imageUrl = snapshot.get('imageUrl') ?? '';
          });
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Future<void> updateProfileData() async {
    try {
      String? uid = AuthService.getCurrentUserUID();

      if (uid != null) {
        if (_profileImage != null) {
          String fileName = 'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('profile_images').child(fileName);
          UploadTask uploadTask = firebaseStorageRef.putFile(_profileImage!);
          TaskSnapshot taskSnapshot = await uploadTask;
          _imageUrl = await taskSnapshot.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _fullNameController.text,
          'username': _usernameController.text,
          'about': _aboutController.text,
          'phone': _phoneController.text,
          'imageUrl': _imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context); // Go back to the profile screen
      }
    } catch (e) {
      print("Error updating profile data: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : (_imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null) as ImageProvider?,
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _aboutController,
              decoration: InputDecoration(labelText: 'About'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfileData,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
