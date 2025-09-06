import 'package:flutter/material.dart';
import '../services/account_service.dart';
import 'transfer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _svc = AccountService();
  int _balanceCents = 100000; // $1,000.00 mock

  @override
  void initState() {
    super.initState();
    _balanceCents = _svc.currentBalanceCents;
  }

  @override
  Widget build(BuildContext context) {
    final balance = (_balanceCents / 100).toStringAsFixed(2);
    return Scaffold(
      appBar: AppBar(title: const Text('Banking Manager')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, size: 72),
            const SizedBox(height: 12),
            const Text('Available Balance', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text('\$$balance',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final updated = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (_) => TransferScreen(balanceCents: _balanceCents)),
                );
                if (updated != null) setState(() => _balanceCents = updated);
              },
              child: const Text('Make Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
