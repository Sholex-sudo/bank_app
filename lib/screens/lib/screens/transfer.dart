import 'package:flutter/material.dart';
import '../services/account_service.dart';

class TransferScreen extends StatefulWidget {
  final int balanceCents;
  const TransferScreen({super.key, required this.balanceCents});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  bool _loading = false;
  final _svc = AccountService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _toCtrl,
                decoration: const InputDecoration(
                  labelText: 'To (Account or Email)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter recipient' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (USD)',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  if (n * 100 > widget.balanceCents) return 'Insufficient funds';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _loading = true);
                    final cents = (double.parse(_amountCtrl.text) * 100).round();
                    final newBal = await _svc.mockTransfer(
                      to: _toCtrl.text.trim(), amountCents: cents);
                    if (!mounted) return;
                    setState(() => _loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer submitted')),
                    );
                    Navigator.pop(context, newBal);
                  },
                  child: _loading ? const CircularProgressIndicator() : const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
