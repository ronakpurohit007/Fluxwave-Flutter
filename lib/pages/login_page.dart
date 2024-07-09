import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Login/sign_up.dart';
import '../controller/auth_service.dart';
import '../home/navigation_bar.dart';
import '../Login/sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  late String _verificationId = "";

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("images/name_logo1.png", width: 220),
                SizedBox(height: 20),
                Text(
                  "Phone Verification",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "We need to register your phone before getting started",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      labelText: "Enter your Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendOtp();
                      }
                    },
                    child: Text("Send OTP"),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your phone number");
      return;
    }

    try {
      await AuthService.sendOtp(
        phone: phone,
        errorStep: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error in Sending OTP",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
        nextStep: (verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("OTP Verification"),
              content: Form(
                key: _otpFormKey,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter OTP",
                    fillColor: Colors.grey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return "Please enter valid 6 Digit OTP";
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_otpFormKey.currentState!.validate()) {
                      String otp = _otpController.text.trim();
                      try {
                        String loginResult = await AuthService.loginWithOtp(
                          otp: otp,
                          verificationId: _verificationId,
                        );

                        if (loginResult == "Success") {
                          bool profileExists =
                              await AuthService.checkUserExists();
                          if (profileExists) {
                            Navigator.pop(context); // Close OTP dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BottomNavBar(),
                              ),
                            );
                          } else {
                            Navigator.pop(context); // Close OTP dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SignUpScreen(phoneNumber: phone),
                              ),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(msg: loginResult);
                        }
                      } catch (error) {
                        Fluttertoast.showToast(msg: "Failed to login: $error");
                      }
                    }
                  },
                  child: Text("Submit"),
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send OTP: $e");
    }
  }
}
