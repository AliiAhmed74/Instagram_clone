import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/generated/l10n.dart';
import 'package:instagram_clone/views/FeedPost.dart';
import 'package:instagram_clone/views/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: S.of(context).Email,
                    hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 208, 204, 204),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).Email_is_required;
                    }
                    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return S.of(context).Enter_a_valid_email;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: S.of(context).Password,
                    hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 208, 204, 204),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).Password_is_required;
                    }
                    if (value.length < 6) {
                      return S.of(context).Password_must_be_at_least_6_characters_long;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    GestureDetector(
      onTap: () async {
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
          // Show dialog on success
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:  Text(S.of(context).Success),
                content:  Text(S.of(context).Password_must_be_at_least_6_characters_long),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(S.of(context).OK),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          // Show dialog on failure
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:  Text(S.of(context).Error),
                content: Text(S.of(context).Failed_to_send_password_reset_email),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child:  Text(S.of(context).OK),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        child:  Text(
          S.of(context).Forget_Password,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ],
),

                const SizedBox(height: 80),
                _isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FeedPost(),
                                ),
                              );
                              print(S.of(context).Login_successful);
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              String errorMessage;
                              if (e.code == S.of(context).User_not_found) {
                                errorMessage = S.of(context).No_user_found_for_that_email;
                              } else if (e.code == 'wrong-password') {
                                errorMessage = S.of(context).Wrong_password_provided;
                              } else {
                                errorMessage = S.of(context).An_error_occurred;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
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
                          child:  Center(
                            child: Text(
                              S.of(context).Login,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      S.of(context).Do_not_have_an_email,
                      style: TextStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child:  Text(
                        S.of(context).Sign_up,
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
