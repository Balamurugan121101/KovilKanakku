# 🛕 Kovil Kanakku

A simple, lightweight and open-source Flutter application for managing temple donations, expenses, events and financial reports.

Kovil Kanakku is designed for small temples that need a simple way to record income and expenses, generate donation receipts and view basic financial reports.

\---

## ✨ Features

* 🛕 Temple dashboard
* 💰 Donation management
* 🧾 Donation receipt generation
* 📄 Receipt PDF preview
* 🖨️ Print receipts
* 📤 Share receipts
* 💸 Expense management
* 📅 Event management
* 🔗 Link donations to events
* 🔗 Link expenses to events
* 📊 Financial reports
* 📄 PDF financial reports
* 📅 Date-based reports
* 🎯 Event-based reports
* 🔐 Firebase Authentication
* ☁️ Cloud Firestore
* 📱 Android support
* 🍎 iOS support

\---

## 🛠️ Tech Stack

|Technology|Purpose|
|-|-|
|Flutter|Mobile application|
|Dart|Programming language|
|Firebase Authentication|User authentication|
|Cloud Firestore|Database|
|FlutterFire|Firebase integration|
|Riverpod|State management|
|GoRouter|Navigation|
|Freezed|Data models|
|PDF|PDF generation|
|Printing|Print/share PDF documents|
|Intl|Currency and date formatting|

\---

## 📱 Supported Platforms

Currently supported:

* Android
* iOS

\---

## 🏗️ Architecture

```text
┌──────────────────────────┐
│          UI              │
│       Flutter Pages      │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│       Riverpod           │
│        Providers         │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│      Repositories        │
│ Donation / Expense /     │
│ Event / User / Settings  │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│        Firebase          │
│ Authentication +         │
│ Cloud Firestore          │
└──────────────────────────┘
```

\---

## 📂 Project Structure

```text
lib/
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── routes.dart
│   └── theme.dart

│
├── models/
│   ├── donation\_model.dart
│   ├── expense\_model.dart
│   ├── event\_model.dart
│   ├── settings\_model.dart
│   └── user\_model.dart
│
├── pages/
│   ├── auth/
│   ├── dashboard/
│   ├── donations/
│   ├── expenses/
│   ├── events/
│   ├── reports/
│   └── settings/
│
├── providers/
│   ├── donation\_provider.dart
│   ├── expense\_provider.dart
│   ├── event\_provider.dart
│   └── report\_provider.dart
│
├── repositories/
│   ├── donation\_repository.dart
│   ├── expense\_repository.dart
│   ├── event\_repository.dart
│   ├── user\_repository.dart
│   └── settings\_repository.dart
│
├── services/
│   ├── receipt\_service.dart
│   └── report\_pdf\_service.dart
│
├── firebase\_options.dart
│
└── main.dart
```

\---

# 🚀 Getting Started

## Prerequisites

Install:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Xcode (for iOS development)
* Firebase CLI
* FlutterFire CLI

Check Flutter:

```bash
flutter doctor
```

\---

# 1\. Clone the Repository

```bash
git clone https://github.com/Balamurugan121101/KovilKanakku.git
cd KovilKanakku
```

Install dependencies:

```bash
flutter pub get
```

Generate Freezed/JSON files if required:

```bash
dart run build\_runner build --delete-conflicting-outputs
```

\---

# 🔥 Firebase Setup

Kovil Kanakku uses Firebase for:

* Firebase Authentication
* Cloud Firestore

Each installation should use its **own Firebase project**.

Do not connect the open-source application to another person's Firebase project.

\---

# 2\. Create a Firebase Project

Open:

https://console.firebase.google.com/

Click:

```text
Add project
```

Example project name:

```text
kovil-kanakku-demo
```

Follow the Firebase setup wizard and create the project.

\---

# 3\. Install Firebase CLI

Install the Firebase CLI:

https://firebase.google.com/docs/cli

Verify:

```bash
firebase --version
```

Login:

```bash
firebase login
```

Check projects:

```bash
firebase projects:list
```

\---

# 4\. Install FlutterFire CLI

```bash
dart pub global activate flutterfire\_cli
```

Verify:

```bash
flutterfire --version
```

\---

# 5\. Configure Firebase for Flutter

From the root of the Flutter project:

```bash
flutterfire configure
```

Select the Firebase project you created.

Select:

```text
Android
iOS
```

FlutterFire will generate:

```text
lib/firebase\_options.dart
```

The Firebase configuration should be performed separately for each developer/environment.

\---

# 6\. Android Firebase Configuration

During:

```bash
flutterfire configure
```

select Android.

Make sure the Android application ID matches your Firebase Android app.

Check your Flutter Android project in:

```text
android/app/build.gradle
```

or:

```text
android/app/build.gradle.kts
```

The application ID should match the Android app configured in Firebase.

\---

# 7\. iOS Firebase Configuration

Run:

```bash
flutterfire configure
```

and select iOS.

Open the iOS project using:

```text
ios/Runner.xcworkspace
```

in Xcode.

Check:

```text
Runner
→ Targets
→ Runner
→ General
→ Identity
→ Bundle Identifier
```

The bundle identifier must match the Firebase iOS application.

\---

# 🔐 Firebase Authentication

Kovil Kanakku uses Firebase Authentication for application login.

\---

# 8\. Enable Email/Password Authentication

In Firebase Console:

```text
Build
→ Authentication
→ Get started
→ Sign-in method
→ Email/Password
```

Enable:

```text
Email/Password
```

Then click:

```text
Save
```

\---

# 👤 Create the First User

In Firebase Console:

```text
Authentication
→ Users
→ Add user
```

Enter an email and secure password.

Example:

```text
Email: admin@example.com
Password: <YOUR\_SECURE\_PASSWORD>
```

Click:

```text
Add user
```

Firebase will create an Authentication UID for the user.

\---

# ⚠️ Authentication User vs Firestore User

Kovil Kanakku uses both:

1. Firebase Authentication user
2. Firestore application user

The Firebase Authentication UID should be used as the Firestore user document ID.

Example:

```text
Firebase Authentication

UID:
abc123xyz
```

Create:

```text
temples
└── temple001
    └── users
        └── abc123xyz
```

\---

# 🗄️ Firestore Setup

In Firebase Console:

```text
Build
→ Firestore Database
→ Create database
```

Choose an appropriate Firebase region.

\---

# 9\. Firestore Data Structure

The application uses:

```text
temples
└── temple001
    │
    ├── settings
    │   └── config
    │
    ├── users
    │   └── {firebaseUserUid}
    │
    ├── donations
    │   └── {donationId}
    │
    ├── expenses
    │   └── {expenseId}
    │
    └── events
        └── {eventId}
```

\---

# ⚙️ Temple Settings

Create:

```text
temples
└── temple001
    └── settings
        └── config
```

Add:

```text
templeName
address
phone
receiptPrefix
nextReceiptNumber
```

Example:

```json
{
  "templeName": "Sri Murugan Temple",
  "address": "Temple Address, Tamil Nadu",
  "phone": "9876543210",
  "receiptPrefix": "RCT",
  "nextReceiptNumber": 1
}
```

These settings are used for:

* Temple name
* Temple address
* Temple phone
* Receipt generation
* Receipt number generation

Receipt numbers will look like:

```text
RCT-000001
RCT-000002
RCT-000003
```

\---

# 👤 Firestore User Setup

Create:

```text
temples
└── temple001
    └── users
        └── {Firebase Authentication UID}
```

Example:

```text
temples
└── temple001
    └── users
        └── abc123xyz
```

Add:

```text
name
email
role
```

Example:

```json
{
   "name": "Admin",
   "email": "admin@example.com",
   "role": "admin"
}
```

The document ID must be the exact Firebase Authentication UID.

\---

# 💰 Donations

Donation records are stored under:

```text
temples
└── temple001
    └── donations
```

A donation contains:

```text
id
donorName
amount
phone
purpose
eventId
donatedAt
receiptNumber
createdBy
```

Example:

```json
{
   "id": "donation001",
   "donorName": "Ramesh",
   "amount": 5000,
   "phone": "9876543210",
   "purpose": "Annadhanam",
   "eventId": "event001",
   "receiptNumber": "RCT-000001",
   "createdBy": "abc123xyz"
}
```

\---

# 💸 Expenses

Expense records are stored under:

```text
temples
└── temple001
    └── expenses
```

An expense contains:

```text
id
description
amount
category
date
notes
eventId
createdBy
createdAt
```

Example:

```json
{
  "id": "expense001",
  "description": "Flowers for Pooja",
  "amount": 1500,
  "category": "Flowers",
  "date": "2026-08-18",
  "notes": "Weekly flower purchase",
  "eventId": null,
  "createdBy": "abc123xyz"
}
```

\---

# 📅 Events

Events are stored under:

```text
temples
└── temple001
    └── events
```

Donations and expenses can be linked to an event through:

```text
eventId
```

Example:

```text
Event
└── event001
    ├── Donations
    │   ├── donation001
    │   └── donation002
    │
    └── Expenses
        ├── expense001
        └── expense002
```

\---

# 📊 Reports

Reports provide a simple financial overview:

```text
Total Donations
Total Expenses
Balance
Donation Count
Expense Count
Transaction Count
```

Reports can be filtered by:

* Today
* This Week
* This Month
* This Year
* Custom Date Range
* Event

The PDF report contains individual transactions as well as summary information.

\---

# 🧾 Donation Receipts

Donation receipts are generated dynamically.

Generated PDFs do not need to be stored in Firestore.

Receipt information is generated from:

```text
Donation
+
Temple Settings
```

Receipts can be:

* Previewed
* Printed
* Shared

\---

# 🔢 Receipt Number Generation

Receipt numbers use:

```text
receiptPrefix
+
nextReceiptNumber
```

Example:

```text
RCT-000001
RCT-000002
RCT-000003
```

The receipt counter is updated transactionally in Firestore to help prevent duplicate receipt numbers when multiple users create donations.

\---

# 💱 Currency Formatting

Currency values use the Indian numbering system.

Examples:

```text
₹ 1,000.00
₹ 10,000.00
₹ 1,00,000.00
₹ 10,00,000.00
```

\---

# 🔐 Firestore Security Rules

For initial development, authenticated users can be allowed to access temple data:

```text
rules\_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /temples/{templeId}/{document=\*\*} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Production

For production, strengthen the rules so users can access only temples they are authorized to access.

Do not use broad authenticated-user write access for a production financial application without reviewing the authorization model.

\---

# 🚫 Firebase Credentials and Git

Do **not** commit environment-specific Firebase configuration or secrets to the public repository.

Depending on your project setup, keep these out of Git:

```text
lib/firebase\_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

Add appropriate entries to `.gitignore`.

Each developer can configure Firebase locally using:

```bash
flutterfire configure
```

Never commit:

* Passwords
* Private keys
* API secrets
* Real donor data
* Real phone numbers
* Production database exports
* Other sensitive information

\---

# 🧪 Run the Application

Check devices:

```bash
flutter devices
```

Run:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device-id>
```

\---

# 🏗️ Build Android APK

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/
```

\---

# 🍎 Build iOS

On macOS:

```bash
flutter build ios --release
```

For App Store distribution, configure signing and provisioning through Xcode.

\---

# 🧹 Code Generation

The project uses Freezed and JSON serialization.

Regenerate files:

```bash
dart run build\_runner build --delete-conflicting-outputs
```

During development:

```bash
dart run build\_runner watch --delete-conflicting-outputs
```

\---

# 🌍 Multi-Temple Support

The current implementation uses:

```text
temple001
```

as the temple identifier.

This keeps the initial application simple.

A future multi-temple architecture can determine the temple from the authenticated user's membership:

```text
Firebase Authentication
        │
        ▼
      User UID
        │
        ▼
Temple Membership
        │
        ▼
    Temple ID
        │
        ├── Settings
        ├── Users
        ├── Donations
        ├── Expenses
        └── Events
```

\---

# 🤝 Contributing

Contributions are welcome.

Create a feature branch:

```bash
git checkout -b feature/my-feature
```

Format the code:

```bash
dart format .
```

Analyze:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Commit:

```bash
git add .
git commit -m "Add my feature"
```

Push:

```bash
git push origin feature/my-feature
```

Then create a Pull Request.

\---

# 📚 Useful Resources

* Flutter: https://flutter.dev/
* Firebase: https://firebase.google.com/
* Firebase Console: https://console.firebase.google.com/
* Firebase CLI: https://firebase.google.com/docs/cli
* FlutterFire: https://firebase.google.com/docs/flutter/setup
* Firebase Authentication: https://firebase.google.com/docs/auth
* Cloud Firestore: https://firebase.google.com/docs/firestore

\---

# 📜 License

This project is licensed under the MIT License.

See the `LICENSE` file for details.

\---

# ⚠️ Disclaimer

Kovil Kanakku is an open-source software project intended to provide a simple mechanism for recording temple donations, expenses, events and financial reports.

Before using the application for production financial or accounting purposes, review:

* Firebase security rules
* Authentication configuration
* User permissions
* Data privacy requirements
* Backup strategy
* Financial/accounting requirements applicable to your organization

The project maintainers are not responsible for financial loss, incorrect records, data loss or unauthorized access resulting from improper configuration or use of the application.

\---

# 🛕 Kovil Kanakku

**Donations • Expenses • Events • Receipts • Reports**

Made with ❤️ using Flutter and Firebase.

