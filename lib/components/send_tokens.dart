import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class SendTokensPage extends StatelessWidget {
  final String privateKey;
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  late double relamount = 0;
  SendTokensPage({Key? key, required this.privateKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                width: 150,
                height: 200,
                child: Image.asset(
                  'assets/sendm.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            TextFormField(
              controller: recipientController,
              decoration: InputDecoration(
                labelText: 'Recipient Aadhar Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount in Rupees',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String recipient = recipientController.text;

                double amount = double.parse(amountController.text);
                relamount = amount;
                sendTransaction(recipient, amount, context);
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void sendTransaction(String recipient, double amount, BuildContext context) {
    checkAadharNumber(recipient, amount, context);
  }

  Future<void> _saveAndUploadData(double amount, String recipient, String senderAadharNumber, Timestamp timestamp) async {
    Map<String, dynamic> jsonData = {
      'amount': amount.toString(),
      'recipient': recipient,
      'senderAadharNumber': senderAadharNumber,
      'timestamp': timestamp.toString(),
    };

    String jsonString = jsonEncode(jsonData);

    final pinataUrl = Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS');
    final apiKey = 'fdbd39f33988c3575508'; // Replace with your actual Pinata API key
    final apiSecret = 'e4f4368b2a9ac8cbf07f3c5ab94f15e1e0bf7f347256e114b2b25c4ef2dd7af3'; // Replace with your actual Pinata API secret

    final response = await http.post(
      pinataUrl,
      headers: {
        'Content-Type': 'application/json',
        'pinata_api_key': apiKey,
        'pinata_secret_api_key': apiSecret,
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      // Handle successful upload
      print('Data successfully uploaded to Pinata');
    } else {
      // Handle failed upload
      print('Failed to upload data to Pinata: ${response.statusCode}');
    }
  }

  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  void checkAadharNumber(String aadharNumber, double amount, BuildContext context) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (userDoc.exists) {
        double currentBalance = double.parse(userDoc['balance'] ?? '0.0');
        double newBalance = currentBalance - amount;

        if (amount <= currentBalance) {
          await userDoc.reference.update({'balance': newBalance.toString()});

          String senderAadharNumber = userDoc['aadharNumber'];

          QuerySnapshot querySnapshot2 = await usersCollection
              .where('aadharNumber', isEqualTo: recipientController.text)
              .get();

          DocumentSnapshot senderDoc = querySnapshot2.docs.first;
          double currentBalance = double.parse(senderDoc['balance'] ?? '0.0');
          double newBalances = currentBalance + amount;
          await senderDoc.reference.update({'balance': newBalances.toString()});

          await userDoc.reference.collection('transactions').add({
            'recipient': aadharNumber,
            'amount': amount,
            'senderAadharNumber': senderAadharNumber,
            'timestamp': Timestamp.now(),
          });
          await senderDoc.reference.collection('transactions').add({
            'recipent': 'me',
            'amount': amount,
            'senderAadharNumber': senderAadharNumber,
            'timestamp': Timestamp.now(),
          });
          var time = Timestamp.now();
          _saveAndUploadData(amount, aadharNumber, senderAadharNumber, time);

          openInvoiceScreen(senderAadharNumber, aadharNumber, amount, context);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Insufficient Balance"),
                content: Text("Your balance is insufficient for this transaction."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print("User not found");
      }
    } else {
      print("User not logged in");
    }
  }

  void openInvoiceScreen(String senderAadharNumber, String receiverAadharNumber, double amount, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(
          senderAadharNumber: senderAadharNumber,
          receiverAadharNumber: receiverAadharNumber,
          amount: amount,
        ),
      ),
    );
  }
}
class InvoiceScreen extends StatelessWidget {
  final String senderAadharNumber;
  final String receiverAadharNumber;
  final double amount;
  final DateTime currentTime;

  InvoiceScreen({
    required this.senderAadharNumber,
    required this.receiverAadharNumber,
    required this.amount,
  }) : currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Container(
              width: double.infinity, // Set width to fill the screen
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Invoice Details",
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10.0),
                      _buildDetailRow("Sender Aadhar Number:", senderAadharNumber),
                      _buildDetailRow("Receiver Aadhar Number:", receiverAadharNumber),
                      _buildDetailRow("Amount:", "Rs. $amount"),
                      _buildDetailRow("Time:", currentTime.toString()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5.0),
        Text(
          value,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
}
