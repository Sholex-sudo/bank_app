class AccountService {
  int _balanceCents = 100000; // seed $1,000.00

  int get currentBalanceCents => _balanceCents;

  Future<int> mockTransfer({required String to, required int amountCents}) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    _balanceCents -= amountCents;
    return _balanceCents;
  }
}
