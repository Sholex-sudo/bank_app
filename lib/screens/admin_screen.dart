import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txCol = FirebaseFirestore.instance.collection('transactions');

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: txCol.orderBy('createdAt', descending: true).limit(50).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final created = (d['createdAt'] as Timestamp?)?.toDate();
              final when = created != null ? DateFormat.yMd().add_jm().format(created) : '-';
              return ListTile(
                title: Text('${d['type']} ${d['amountCents']}¢  (${d['status']})'),
                subtitle: Text('uid: ${d['uid']}  desc: ${d['description'] ?? ''}\n$when'),
              );
            },
          );
        },
      ),
    );
  }
}