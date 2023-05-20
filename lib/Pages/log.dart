// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../extras/deco.dart';
import '../extras/snackbar.dart';
import 'Registerpage.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey2 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Check if email and password are valid
    if (email.isEmpty || !email.contains('@')) {
      showSnackBar(context, 'Please enter a valid email address.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      showSnackBar(
          context, 'Please enter a password with at least 6 characters.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      showSnackBar(context, 'Signed in');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, 'Wrong password provided for that user.');
      }
    } catch (e) {
      showSnackBar(context, 'Error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login Page",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Form(
        key: _formKey2,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Email textfield
              SizedBox(
                width: 300.0,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  decoration: getTextFieldDecoration(context).copyWith(
                    hintText: "Enter Your Email : ",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(
                height: 20,
              ),
              // password textfield
              SizedBox(
                width: 300.0,
                child: TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: _isObscure ? true : false,
                  decoration: getTextFieldDecoration(context).copyWith(
                    hintText: "Enter Your Password : ",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password should be at least 8 characters long';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                        padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                      ),
                      child: Text('Log in'),
                      onPressed: () async {
                        if (_formKey2.currentState!.validate()) {
                          await _signIn();
                          if (!mounted) return;
                      
                        }
                      }),
              SizedBox(height: 10),
              Text('or'),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                  padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                ),
                child: Text('Create Account'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
