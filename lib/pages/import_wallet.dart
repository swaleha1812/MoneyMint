import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3_wallet/pages/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../mainscreenn.dart';

class ImportWallet extends StatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  String adharNumber = '';
  String password = '';
  String mnemonic = '';

  void navigateToWalletPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomNavigationExample()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> verifyUser() async {
      Provider.of<WalletProvider>(context, listen: false);

      // Search Firestore for user based on Aadhar number and password

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('aadharNumber', isEqualTo: adharNumber)
          .where('pass', isEqualTo: password)
          .get();
      // QuerySnapshot querySnapshot = await usersCollection
      //     .where('aadharNumber', isEqualTo: adharNumber)
      //     .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User found
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        // Fetch mnemonic from the user document
        mnemonic = userDoc['mnemonic'];

        // Call the getPrivateKey function from the WalletProvider with mnemonic

        // Navigate to the WalletPage
        navigateToWalletPage();
      } else {
        // User not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Invalid Aadhar number or password.'),
              actions: <Widget>[

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF031273), // Set app bar color to #031273
        elevation: 0,
        title: Text(
          'Login',
          style: TextStyle(color: Colors.white), // Set title color to white
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // match screen height
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100), // Added space of 100 pixels between app bar and card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 150,
                          height: 200,
                          child: Image.asset(
                            'assets/logo_moneymint.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      Text(
                        'Login Here!!',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Helvetica Rounded',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            adharNumber = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Mint_id',
                          hintText: 'Enter Mint_id',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 35), // Added space of 50 pixels between the text fields
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 10.0), // Added spacing between the text fields
                      ElevatedButton(
                        onPressed: verifyUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF031273), // Button color
                          elevation: 4, // Button shadow
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white), // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
