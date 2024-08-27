import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet/pages/create_or_import.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: ProfileInfo(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('privateKey');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrImportPage(),
      ),
          (route) => false,
    );
  }
}

class ProfileInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('User data not found.'),
            );
          }

          Map<String, dynamic> userData =
          snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              ProfileField(label: 'Name', value: userData['name']),
              ProfileField(
                  label: 'Aadhar Number', value: userData['aadharNumber']),
              ProfileField(label: 'Date of Birth', value: userData['dob']),
              ProfileField(label: 'Email', value: userData['email']),
              ProfileField(label: 'Mnemonic', value: userData['mnemonic']),
              ProfileField(label: 'PAN Card', value: userData['panCard']),
            ].map((profileField) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: profileField,
              );
            }).toList(),
          );
        },
      );
    } else {
      return Center(
        child: Text('User not logged in.'),
      );
    }
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
