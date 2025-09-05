# Banking Manager (Flutter + Firebase) — Starter

**Educational starter** for a banking-style app with admin/user roles, available balance, and SMS/email alerts.

> ⚠️ For demos only. If you plan to handle real money, consult legal/compliance experts, complete PCI/PII reviews, and hire a security audit.

## Features
- Firebase Auth (email/password)
- Firestore: users, accounts, transactions
- Callable Cloud Function `performTransaction` for server-side balance updates
- Alerts via SendGrid (email) and Twilio (SMS) after each transaction
- Admin panel to view recent transactions
- Basic Firestore rules to block client-side balance writes

## Setup

1. Create Flutter project and add deps (see `pubspec_snippet.yaml`).
2. `dart pub get`
3. Create a Firebase project and run `flutterfire configure`.
4. Enable Auth provider (Email/Password). Create test users in Console; add `role: "admin"` for admin users.
5. Firestore:
   - Create `users/{uid}` with fields `{ email, phone, role }`.
   - Create `accounts/{uid}` with `{ balanceCents: 100000 }` for seed balances.
6. Deploy rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
7. Cloud Functions:
   ```bash
   cd functions
   npm i
   firebase functions:config:set sendgrid.key="SG_xxx" sendgrid.from="no-reply@yourapp.com"
   firebase functions:config:set twilio.sid="ACxxx" twilio.token="xxx" twilio.from="+12345556789"
   firebase deploy --only functions
   ```
8. Run the app on Android/iOS.

## Notes
- `performTransaction` enforces atomic balance updates and prevents client tampering.
- Replace alerts with your preferred providers if needed.