import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    try {
      Reference ref = _storage.ref().child(childName);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<String> saveData({
    required String name,
    required String username,
    required String about,
    required String phone,
    required Uint8List file,
  }) async {
    String response = "Some Error Occurred";
    try {
      if (name.isNotEmpty && username.isNotEmpty && about.isNotEmpty && phone.isNotEmpty) {
        String imageUrl = await uploadImageToStorage('profileImage', file);
        await _firestore.collection('userProfile').add({
          'name': name,
          'username': username,
          'about': about,
          'phone': phone,
          'imageLink': imageUrl
        });
        response = 'success';
      } else {
        response = "Please fill in all fields.";
      }
    } catch (err) {
      response = err.toString();
    }
    return response;
  }
}
