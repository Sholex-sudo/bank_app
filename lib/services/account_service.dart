import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/account.dart';

class AccountService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _func = FirebaseFunctions.instance;

  Stream<Account?> myAccountStream() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('accounts').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Account.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> performTransaction({
    required int amountCents,
    required String type, // 'credit' | 'debit' | 'transfer'
    String? description,
    String? toUid, // for transfer
  }) async {
    final uid = _auth.currentUser!.uid;
    final callable = _func.httpsCallable('performTransaction');
    await callable.call({
      'uid': uid,
      'amountCents': amountCents,
      'type': type,
      'description': description,
      'toUid': toUid,
    });
  }
}