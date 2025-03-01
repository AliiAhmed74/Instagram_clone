import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/LoginPage.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  @override
  Widget build(BuildContext context) {

  Future<void> addUserDetails(String email, String fullName, String username, int phoneNumber, String gender) async {
  final userId = FirebaseAuth.instance.currentUser!.uid; // Get the current user's ID
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'email': email,
    'fullName': fullName,
    'username': username,
    'phoneNumber': phoneNumber,
    'gender': gender,
    'uid':userId,
  });
}

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Image.asset(
                    Theme.of(context).brightness == Brightness.light
                        ? 'assets/instagram_text.png' // Light mode image
                        : 'assets/Instagram_text2.png', // Dark mode image
                  width: 250,
                  ),
                  SizedBox(height: 20),
                  // Email Field
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: S.of(context).Email,
                        hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 208, 204, 204),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).Please_enter_your_email;
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return S.of(context).Please_enter_a_valid_email;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Full Name Field
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: S.of(context).FullName,
                        hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 208, 204, 204),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).Please_enter_your_fullname;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Username Field
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: S.of(context).Username,
                        hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 208, 204, 204),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).Please_enter_your_username;
                        } else if (value.length < 3) {
                          return S.of(context).Username_must_be_at_least_3_characters_long;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password Field
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: S.of(context).Password,
                        hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 208, 204, 204),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).Please_enter_your_password;
                        } else if (value.length < 6) {
                          return S.of(context).Password_must_be_at_least_6_characters_long;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Phone Number Field
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: S.of(context).Phone_Number,
                        hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 208, 204, 204),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).Please_enter_your_phone_number;
                        } else if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                          return S.of(context).Please_enter_a_valid_phone_number;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Gender Field
                  Container(
                    width: 400,
                    child: TextFormField(
                      controller: genderController,
                      decoration: InputDecoration(
                        hintText: S.of(context).Gender_Male_Female,
                        hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 208, 204, 204),
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).Please_enter_your_gender;
                        } else if (value.toLowerCase() != 'male' &&
                            value.toLowerCase() != 'female') {
                          return S.of(context).Gender_must_be_Male_or_Female;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 80),
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        // Form is valid
                        try {
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                          addUserDetails(
                            emailController.text.trim(),
                            fullNameController.text.trim(),
                            usernameController.text.trim(),
                            int.parse(phoneNumberController.text.trim()),
                            genderController.text.trim());
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => FeedPost()),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message = S.of(context).An_error_occurred;
                          if (e.code == 'weak-password') {
                            message = S.of(context).The_password_provided_is_too_weak;
                          } else if (e.code == 'email-already-in-use') {
                            message =
                                S.of(context).The_account_already_exists_for_that_email;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: Container(
                      width: 400,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 44, 171, 235),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          S.of(context).Sign_up,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).By_signing_up_you_agree_to_our_terms_Data,
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        S.of(context).Policy_and_Cookies_Policy,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).Have_an_account,
                        style: TextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          S.of(context).Login,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
