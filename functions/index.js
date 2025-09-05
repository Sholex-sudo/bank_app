import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import sgMail from '@sendgrid/mail';
import twilio from 'twilio';

admin.initializeApp();

// Config: set via `firebase functions:config:set`
// sendgrid.key=... sendgrid.from=...
// twilio.sid=... twilio.token=... twilio.from=...
const cfg = functions.config();
if (cfg.sendgrid?.key) sgMail.setApiKey(cfg.sendgrid.key);

const twilioClient = (cfg.twilio?.sid && cfg.twilio?.token)
  ? twilio(cfg.twilio.sid, cfg.twilio.token) : null;

const db = admin.firestore();

export const performTransaction = functions.https.onCall(async (data, context) => {
  const authUid = context.auth?.uid;
  if (!authUid) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');

  const { uid, amountCents, type, description, toUid } = data;
  if (uid !== authUid) {
    throw new functions.https.HttpsError('permission-denied', 'Can only operate on your account');
  }
  if (!Number.isInteger(amountCents) || amountCents <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'amountCents must be a positive integer');
  }
  if (!['credit','debit','transfer'].includes(type)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid type');
  }

  const userRef = db.collection('users').doc(uid);
  const acctRef = db.collection('accounts').doc(uid);
  const txRef = db.collection('transactions').doc();

  const result = await db.runTransaction(async (trx) => {
    const acctSnap = await trx.get(acctRef);
    let balance = acctSnap.exists ? (acctSnap.data().balanceCents || 0) : 0;

    if (type === 'debit' || type === 'transfer') {
      if (balance < amountCents) throw new functions.https.HttpsError('failed-precondition', 'Insufficient funds');
      balance -= amountCents;
    } else if (type === 'credit') {
      balance += amountCents;
    }
    trx.set(acctRef, { balanceCents: balance, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

    // If transfer, credit recipient
    if (type === 'transfer') {
      if (!toUid) throw new functions.https.HttpsError('invalid-argument', 'toUid required for transfer');
      const recipRef = db.collection('accounts').doc(toUid);
      const recipSnap = await trx.get(recipRef);
      const recipBal = (recipSnap.exists ? (recipSnap.data().balanceCents || 0) : 0) + amountCents;
      trx.set(recipRef, { balanceCents: recipBal, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    }

    trx.set(txRef, {
      uid, amountCents, type, description: description || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'posted'
    });

    return { balance };
  });

  // Fetch contact details to notify
  const userSnap = await userRef.get();
  const email = userSnap.data()?.email;
  const phone = userSnap.data()?.phone;

  const humanAmount = (amountCents / 100).toFixed(2);
  const msg = `[Banking Manager] ${type.toUpperCase()} \$${humanAmount}. Status: posted.`;

  // Email via SendGrid
  if (sgMail && cfg.sendgrid?.from && email) {
    await sgMail.send({
      to: email, from: cfg.sendgrid.from,
      subject: `Transaction ${type} \$${humanAmount}`,
      text: msg
    }).catch((e) => console.error('SendGrid error', e.message));
  }

  // SMS via Twilio
  if (twilioClient && cfg.twilio?.from && phone) {
    await twilioClient.messages.create({
      to: phone, from: cfg.twilio.from, body: msg
    }).catch((e) => console.error('Twilio error', e.message));
  }

  return result;
});