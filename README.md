# BirtaKhabar (Flutter App)

Real-time local news and emergency alert mobile application for Birtamode
and the surrounding Jhapa district. Built as a college-project MVP with
Flutter + Firebase.

## MVP Features (implemented)

- **Auth & Admin Login** — email/password login and registration. The same
  login form works for residents and admins; after signing in, the app
  reads the user's `role` field from Firestore and routes them to either
  the resident tabs or the Admin Dashboard.
- **Facebook-style Home Feed**
  - "What's happening in Birtamode?" header that opens the tip form.
  - Pinned red emergency banner (color-coded by severity) shown whenever
    there is an active alert.
  - Post cards with publisher name, relative time (`timeago`), image
    placeholder, and Like / Comment / Save / Share-to-WhatsApp actions.
  - Inline "Sponsored" ad card embedded every 4 posts in the stream.
- **Emergency Alerts screen** — all active alerts, sorted critical → low.
- **Community Tip Submission form** — title, location, description, photo
  picker (uploads to Firebase Storage), saved to Firestore with
  `status: pending`.
- **Admin Dashboard** — three tabs: approve/reject pending tips, publish a
  news article, and broadcast/resolve emergency alerts.
- **Premium Subscription screen** — mock eSewa / Khalti test-mode "payment"
  buttons that flip the user's `isPremium` flag (Rs. 99/month, ad-free).

## Not yet implemented (future work)

Full React.js web admin dashboard, business listings/advertising module,
live (non-sandbox) eSewa/Khalti payments, and push-notification Cloud
Functions. The Firestore data model already includes a `businesses`
collection and an `isPremium` flag on `AppUser` so these can be added
without restructuring data.

## Data model

| Model | Key fields |
|---|---|
| `UserModel` | id, name, email, phone, ward, role ('user'/'admin'), isPremium, fcmToken |
| `ArticleModel` | id, title, content, category, imageUrl, authorName/Id, timestamp, likesCount, views, isVerified |
| `AlertModel` | id, title, description, severity (low/medium/critical), area, postedByName, timestamp, isActive |
| `TipModel` | id, userId, title, location, description, imageUrl, submittedByName, contactPhone, status (pending/approved/rejected) |

## Project structure

```
lib/
  main.dart                  # App entry point, Firebase init, AuthGate
  firebase_options.dart      # Placeholder - regenerate with flutterfire configure
  models/                    # UserModel, ArticleModel, AlertModel, TipModel
  services/
    auth_service.dart        # FirebaseAuth wrapper + Firestore profile lookup
    firestore_service.dart   # All Firestore reads/writes in one place
  providers/
    auth_provider.dart       # Current user + login/register/logout (ChangeNotifier)
    news_provider.dart       # Live streams for articles/alerts/tips (ChangeNotifier)
  screens/
    login_screen.dart
    register_screen.dart
    main_navigation.dart     # Bottom nav shell, role-based tabs
    home_screen.dart         # Facebook-style feed
    alerts_screen.dart
    tip_submission_screen.dart
    admin_dashboard_screen.dart
    premium_screen.dart
  widgets/
    app_header.dart, alert_banner.dart, ad_card.dart, post_card.dart
```

## Setup

1. **Install Flutter** (stable channel) — https://docs.flutter.dev/get-started/install
2. **Create a Firebase project**, enable Authentication (Email/Password), Firestore, Storage, Cloud Messaging.
3. **Generate Firebase config** (overwrites the placeholder `lib/firebase_options.dart`):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. **Install dependencies:**
   ```bash
   flutter pub get
   ```
5. **Deploy Firestore security rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```
6. **Create your first admin account:** register normally in the app, then
   in the Firebase console manually change that user's `role` field in
   `users/{uid}` from `user` to `admin`. Log out and back in to see the
   Admin Dashboard tab appear.
7. **Seed demo data (optional):**
   ```bash
   cd scripts
   npm install firebase-admin
   node seed_data.js
   ```
8. **Run the app:**
   ```bash
   flutter run
   ```

## Notes on notifications

`firebase_messaging` and `flutter_local_notifications` are included in
`pubspec.yaml` for future push-notification work, but the MVP focuses on
Firestore's real-time `snapshots()` streams (see `NewsProvider`), which is
enough to demo live updates: open the Admin Dashboard on one device/emulator
and the Home Feed on another to show a published article or alert appearing
instantly.

To go further, add a Cloud Function that triggers on writes to
`news/{id}` or `alerts/{id}` and sends an FCM push to subscribed devices.
