import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<void> sendOtp({
    required String phone,
    required Function errorStep,
    required Function nextStep,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      timeout: Duration(seconds: 30),
      phoneNumber: "+91$phone",
      verificationCompleted: (phoneAuthCredential) async {
        return;
      },
      verificationFailed: (error) async {
        errorStep();
        return;
      },
      codeSent: (verificationId, forceResendingToken) async {
        nextStep(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    );
  }

  static Future<String> loginWithOtp({
    required String otp,
    required String verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _firebaseAuth.signInWithCredential(credential);
      return "Success";
    } catch (e) {
      return "Failed to verify OTP: $e";
    }
  }

  static Future<bool> checkUserExists() async {
    var user = _firebaseAuth.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.exists;
    }
    return false;
  }

  static String? getCurrentUserUID() {
    var user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  static Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }
}
