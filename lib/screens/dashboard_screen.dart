import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/account_service.dart';
import '../models/account.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AccountService();
    return StreamBuilder<Account?>(
      stream: service.myAccountStream(),
      builder: (context, snap) {
        final acct = snap.data;
        final balance = NumberFormat.simpleCurrency().format((acct?.balanceCents ?? 0) / 100.0);
        return Scaffold(
          appBar: AppBar(title: const Text('My Account'), actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransferScreen())),
            )
          ]),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Available Balance', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(balance, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Make Transfer (demo)'),
                  onPressed: () async {
                    await service.performTransaction(
                      amountCents: 500, type: 'debit', description: 'Coffee');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction submitted')));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final amountC = TextEditingController(text: '1000');
    final toUidC = TextEditingController();
    final service = AccountService();
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: amountC, decoration: const InputDecoration(labelText: 'Amount (cents)')),
            TextField(controller: toUidC, decoration: const InputDecoration(labelText: 'Recipient UID')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await service.performTransaction(
                  amountCents: int.parse(amountC.text),
                  type: 'transfer',
                  toUid: toUidC.text.trim(),
                  description: 'P2P transfer',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer submitted')));
                }
              },
              child: const Text('Send'),
            )
          ],
        ),
      ),
    );
  }
}