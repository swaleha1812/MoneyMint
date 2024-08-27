import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3_wallet/pages/create_or_import.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_wallet/utils/get_balances.dart';
import 'package:web3_wallet/components/nft_balances.dart';
import 'package:web3_wallet/components/send_tokens.dart';
import 'dart:convert';

import '../qrcodegenrate.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';
  String newBalance = '';
  String anumber = '';

  @override
  void initState() {
    super.initState();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    print("here");

    if (user != null) {
      print("User is signed in with UID: ${user.uid}");
      String uid = user.uid;
      try {
        DocumentSnapshot walletSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (walletSnapshot.exists) {
          print("atexists");
          String? walletAddressFromFirestore =
          walletSnapshot.get('aadharNumber');
          if (walletAddressFromFirestore != null) {
            print("at 63");
            newBalance = walletSnapshot['balance'] ?? '0';
            anumber = walletSnapshot['aadharNumber'] ?? '0';
            walletAddress = anumber;
            print("thedata");
            print(newBalance);

            print("78");

            // Transform balance from wei to ether
            EtherAmount latestBalance = EtherAmount.fromBigInt(
                EtherUnit.wei, BigInt.parse(newBalance));
            String latestBalanceInEther =
            latestBalance.getValueInUnit(EtherUnit.ether).toString();

            setState(() {
              balance = newBalance;
            });
          } else {
            print("Wallet address not found in Firestore for user: $uid");
            // Handle case where wallet address is not found in Firestore
            // For example, prompt user to create or import a wallet
          }
        } else {
          print("Wallet document does not exist in Firestore for user: $uid");
          // Handle case where wallet document does not exist in Firestore
          // For example, prompt user to create or import a wallet
        }
      } catch (e) {
        print('Error loading wallet data: $e');
        // Handle error loading wallet data
      }
    } else {
      print("User is not signed in");
      // Handle case where user is not logged in
      // For example, prompt user to log in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // Update any necessary state variables or perform any actions to refresh the widget
                loadWalletData();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],

      ),
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: SizedBox(
              width: 150,
              height: 200,
              child: Image.asset(
                'assets/images/wallet.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          const SizedBox(height: 50.0),
          Card(
            elevation: 3,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Wallet Address',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    walletAddress,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 3,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    newBalance,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'sendButton',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SendTokensPage(privateKey: pvKey),
                            ),
                          );

                        },
                        child: Icon(Icons.send),
                      ),
                      SizedBox(height: 2.0),
                      Text('Send'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'Recive',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QRCodePage(data: anumber),
                            ),
                          );
                        },
                        child: Icon(Icons.money_rounded),
                      ),
                      SizedBox(height: 20.0),
                      Text('Receive'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                // Add your tab contents here
              ),
            ),
          ),
        ],
      ),
    );
  }
}
