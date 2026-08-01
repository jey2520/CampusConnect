# CampusConnect - Buy. Sell. Connect. 🎓💼🤝

A premium, modern, clean, minimalist mobile UI/UX application designed for university campus marketplaces. Built with **Flutter**, **Firebase**, and **Material 3**, utilizing **Riverpod** for state management and **GoRouter** for routing.

---

## 🛠️ Tech Stack & Architecture
- **Framework**: Flutter (Web, Android & iOS)
- **State Management**: Flutter Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`)
- **Authentication**: Firebase Authentication (`firebase_auth`) + Official Google Sign-In SDK
- **Database**: Cloud Firestore (`cloud_firestore`)
- **File Storage**: Firebase Storage (`firebase_storage`)
- **Hosting**: Firebase Hosting (live preview prototype available)

---

## 🔒 Firebase Configuration & Setup Guide

To connect the application to your own production Firebase project, follow these steps:

### 1. Create a Firebase Project
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `CampusConnect`.
3. Enable **Google Analytics** (recommended).

### 2. Enable Authentication & Google Sign-In
1. Navigate to **Build > Authentication > Sign-in method**.
2. Click **Add new provider** and select **Google**.
3. Enable the provider, select your project support email, and click **Save**.
4. Under **Web SDK configuration**, copy the **Web client ID** and **Web client secret** (you will need these for Google OAuth client settings).

### 3. Configure Google OAuth Consent Screen
1. Go to the [Google Cloud Console Credentials Page](https://console.cloud.google.com/apis/credentials).
2. Select your Firebase project.
3. Click on the **OAuth consent screen** tab.
4. Set the **User Type** to **External** (or Internal if restricted to your university domain).
5. Add scopes: `.../auth/userinfo.email` and `.../auth/userinfo.profile`.
6. Add your domain (`github.io`, `firebaseapp.com`) to the **Authorized domains** list.

---

## 📱 Platform Configuration Setup

### Android Setup
1. Generate your debug/release SHA-1 fingerprint:
   ```bash
   # Windows PowerShell
   keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
   ```
2. Copy the **SHA-1** fingerprint.
3. In the Firebase Console, go to **Project settings > General**.
4. Under **Your apps**, select your Android app and paste the SHA-1 fingerprint into **SHA certificate fingerprints**.
5. Download the `google-services.json` and place it under `android/app/google-services.json`.

### iOS Setup
1. In the Firebase Console, select your iOS app under **Project settings > General**.
2. Add your **App Store ID** and **Team ID**.
3. Download the `GoogleService-Info.plist` and place it in the root of your Xcode project runner.
4. Open `ios/Runner/Info.plist` and add the `CFBundleURLTypes` section containing your **REVERSED_CLIENT_ID** (retrieved from `GoogleService-Info.plist`):
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

### Web Setup
1. For Flutter Web Google Sign-In, ensure the client ID is registered in `web/index.html` inside a meta tag:
   ```html
   <meta name="google-signin-client_id" content="558848717390-lg0at8k6bfpt09tpjb08kh3et94m4o9e.apps.googleusercontent.com">
   ```

---

## ⚡ Deployment & Security Rules

### Firestore Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return isAuthenticated() && request.auth.uid == userId; }

    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    match /items/{itemId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.sellerUid == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.sellerUid == request.auth.uid;
    }
    match /chats/{chatId} {
      allow read, write: if isAuthenticated() && (request.auth.uid in resource.data.participants);
    }
  }
}
```

### Storage Security Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return isAuthenticated() && request.auth.uid == userId; }

    match /users/{userId}/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) && request.resource.size < 5 * 1024 * 1024;
    }
    match /items/{itemId}/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.resource.size < 10 * 1024 * 1024;
    }
  }
}
```

### Build & Run Commands
- **Install packages**: `flutter pub get`
- **Run Android/iOS/Web**: `flutter run`
- **Deploy to Firebase Hosting**:
  ```bash
  flutter build web --release
  firebase deploy --only hosting
  ```
