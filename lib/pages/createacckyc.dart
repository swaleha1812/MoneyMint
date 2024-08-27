import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'generate_mnemonic_page.dart';

class UserDataInputPage extends StatefulWidget {
  @override
  _UserDataInputPageState createState() => _UserDataInputPageState();
}

class _UserDataInputPageState extends State<UserDataInputPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _passcon = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
        picked.toIso8601String().split("T")[0]; // Extract date part only
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user account with email as username and PAN number as password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text, // Using email as username
          password: _panCardController.text, // Using PAN card as password
        );

        // Get user UID
        String uid = userCredential.user!.uid;

        // Add user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'dob': _dobController.text,
          'aadharNumber': _aadharController.text,
          'pass': _panCardController.text,
          'balance': '0.0',
          'panCard': _passcon.text,
        });

        // Navigate to the next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GenerateMnemonicPage(),
          ),
        );
      } catch (e) {
        print('Error creating user: $e');
        // Handle error here
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data Input'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextFormField(
                    controller: _aadharController,
                    decoration: InputDecoration(
                      labelText: 'Aadhar Number',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Aadhar number';
                      }
                      if (value.length != 12) {
                        return 'Aadhar number must be 12 digits';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextFormField(
                    controller: _panCardController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your PAN card';
                      }
                      if (value.length != 10) {
                        return 'PAN card must be 10 alphanumeric characters';
                      }
                      return null;
                    },
                    obscureText: true, // Hide password text
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextFormField(
                    controller: _passcon,
                    decoration: InputDecoration(
                      labelText: 'PAN Card',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your PanCardNumber ';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
