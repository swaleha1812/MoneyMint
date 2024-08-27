import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: TransactionList(),
    );
  }
}

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    print("uidis");
    print(currentUserUid);
    if (currentUserUid != null) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No transactions found.'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Card(
                child: TransactionItem(
                  amount: data['amount'] ?? 'Unknown',
                  recipient: data['recipient'] ?? 'Unknown',
                  senderAadharNumber: data['senderAadharNumber'] ?? 'Unknown',
                  timestamp: data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate()
                      : null,
                ),
              );
            }).toList(),
          );
        },
      );
    } else {
      // Handle case where user is not logged in
      return Center(
        child: Text('User not logged in.'),
      );
    }
  }
}

class TransactionItem extends StatelessWidget {
  final double amount;
  final String recipient;
  final String senderAadharNumber;
  final DateTime? timestamp;

  TransactionItem({
    required this.amount,
    required this.recipient,
    required this.senderAadharNumber,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Amount: $amount'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recipient: $recipient'),
          Text('Sender Aadhar Number: $senderAadharNumber'),
          if (timestamp != null) Text('Timestamp: $timestamp'),
        ],
      ),
    );
  }
}
