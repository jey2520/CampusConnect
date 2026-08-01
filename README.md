# CampusConnect - Buy. Sell. Connect. 🎓💼🤝

A premium, modern, clean, minimalist mobile UI/UX application designed for university campus marketplaces. Built with **Flutter**, **Firebase**, and **Material 3**, utilizing **Riverpod** for state management and **GoRouter** for routing.

---

## Features
- **Multi-User Realtime Integration**: Supports unlimited simultaneous users with distinct user states.
- **Robust Auth**: Email Registration & Login, Google Login, Session persistence, and verification logic.
- **Student Profile**: Custom profiles detailing user's UID, college, department, year, profile image, and bio.
- **Product Catalog**: Live item creations, edits, deletions, searches, and advanced filter metrics (condition, price range, college).
- **Secure Image Uploads**: Automatically compresses and saves images to Firebase Storage with size-restricted policies.
- **Realtime Chat Engine**: Instant direct messaging between buyers and sellers, online status displays, typing states, and read receipts.
- **Live Order Tracking**: An advanced 12-second live tracking simulator with an SVG interactive transit map showing delivery steps.

---

## Tech Stack
- **Framework**: Flutter (Web & Mobile)
- **State Management**: Flutter Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`)
- **Database**: Cloud Firestore (`cloud_firestore`)
- **Authentication**: Firebase Auth (`firebase_auth`)
- **File Storage**: Firebase Storage (`firebase_storage`)
- **Hosting**: Firebase Hosting (available on `https://campusconnect.web.app`)
- **Notifications**: Firebase Cloud Messaging (`firebase_messaging`)

---

## Getting Started

### Prerequisites
1. **Flutter SDK**: Ensure Flutter is installed. [Install Flutter Guide](https://docs.flutter.dev/get-started/install).
2. **Node.js & Firebase CLI**: Required to configure hosting and deploy functions. [Install Node.js](https://nodejs.org/).
   ```bash
   npm install -g firebase-tools
   ```

---

## Installation & Setup

1. **Clone the Repository**:
   ```bash
   git clone <YOUR_GITHUB_REPOSITORY_URL>
   cd "Campus Connect"
   ```

2. **Initialize dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Log in to your Firebase account using the CLI:
     ```bash
     firebase login
     ```
   - Initialize the project workspace:
     ```bash
     firebase init
     ```
     *Select Firestore, Hosting, and Storage options and link it to your Firebase Console project.*

4. **Initialize Flutter Fire Configurations**:
   - Install the FlutterFire CLI globally:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Run configure tool to bind Android, iOS, and Web build platforms:
     ```bash
     flutterfire configure
     ```

---

## Run and Test locally

- **Web Browser**:
  ```bash
  flutter run -d chrome
  ```
- **Mobile Emulator / Device**:
  ```bash
  flutter run
  ```

---

## Deployment to Firebase Hosting

Compile and deploy your web build instantly:
```bash
# Build the production bundle for web
flutter build web --release

# Deploy to Firebase hosting URL
firebase deploy --only hosting
```
Once deployed, the app will be accessible at:
👉 `https://campusconnect.web.app` or `https://campusconnect.firebaseapp.com`

---

## GitHub Release Instructions

Run the following commands to initialize and release to your GitHub repository:
```bash
git init
git add .
git commit -m "Initial CampusConnect Release"
git branch -M main
git remote add origin <YOUR_GITHUB_REPOSITORY_URL>
git push -u origin main
```

---

## License
Distributed under the MIT License. See [LICENSE](file:///c:/Users/Admin/OneDrive/Desktop/Campus%20Connect/LICENSE) for more information.
