import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _postController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadPost() async {
    if (_image == null || _postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and enter post content')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user ID
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user logged in')),
        );
        return;
      }
      final String userId = user.uid;

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save post data to Firestore
      final postRef = await FirebaseFirestore.instance.collection('posts').add({
        'userId': userId,
        'content': _postController.text,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        "likedBy" : [],
        "likeCount" :0

      });

      // Add the user ID and post ID to the new collection
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('userPosts').doc(postRef.id).set({
        'postId': postRef.id,
        'content': _postController.text,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        "likedBy" : [],
        "likeCount" :0

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully')),
      );

      _postController.clear();
      setState(() {
        _image = null;
        _isUploading = false;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "New post",
          style: TextStyle(fontSize: 30, fontFamily: 'Open Sans', fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0), // Adjust the height of the divider
          child: SizedBox(
            height: 15.0,
            child: Divider(color: Colors.grey),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Upload New post",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Enter post content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: Colors.grey[50],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 400,
                  height: 200,
                  child: _image == null
                      ? IconButton(
                    iconSize: 56,
                    icon: Icon(Icons.add),
                    onPressed: _pickImage,
                  )
                      : Image.file(_image!),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadPost,
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}
