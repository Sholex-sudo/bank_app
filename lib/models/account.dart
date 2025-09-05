class Account {
  final String uid;
  final int balanceCents;
  Account({required this.uid, required this.balanceCents});

  factory Account.fromMap(String uid, Map<String, dynamic> data) {
    return Account(uid: uid, balanceCents: (data['balanceCents'] ?? 0) as int);
  }
}