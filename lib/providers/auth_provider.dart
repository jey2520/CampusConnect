import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

class AuthState {
  final UserModel? userModel;
  final bool isLoading;
  final String? error;

  AuthState({
    this.userModel,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? userModel,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      userModel: userModel ?? this.userModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._firestore) : super(AuthState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserProfile(user.uid);
      } else {
        state = AuthState(userModel: null);
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!);
        state = AuthState(userModel: userModel);
      } else {
        state = AuthState(userModel: null, error: "Profile does not exist.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final doc = await _firestore.collection('users').doc(uid).get();
        
        if (!doc.exists) {
          final newUser = UserModel(
            uid: uid,
            fullName: userCredential.user!.displayName ?? 'New Student',
            email: userCredential.user!.email ?? '',
            profilePhoto: userCredential.user!.photoURL ?? '',
            phoneNumber: userCredential.user!.phoneNumber ?? '',
            college: 'SRM University', // Default value
            department: '',
            year: '',
            bio: '',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
            authenticationProvider: 'Google',
            role: 'Student',
            status: 'Active',
          );
          await _firestore.collection('users').doc(uid).set(newUser.toMap());
          state = AuthState(userModel: newUser);
        } else {
          await _firestore.collection('users').doc(uid).update({
            'lastLogin': Timestamp.fromDate(DateTime.now()),
          });
          await _fetchUserProfile(uid);
        }
        return true;
      }
      return false;
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    if (state.userModel == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _firestore.collection('users').doc(updatedUser.uid).set(updatedUser.toMap());
      state = AuthState(userModel: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      state = AuthState(userModel: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> deleteAccount() async {
    if (state.userModel == null) return false;
    final uid = state.userModel!.uid;
    state = state.copyWith(isLoading: true);
    try {
      // 1. Delete document from Firestore
      await _firestore.collection('users').doc(uid).delete();
      
      // 2. Sign out Google
      await GoogleSignIn().signOut();
      
      // 3. Delete firebase Auth user
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
      
      state = AuthState(userModel: null);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthNotifier(auth, firestore);
});
