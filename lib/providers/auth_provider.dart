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
        state = AuthState(error: "User profile does not exist inside database.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String college,
    required String department,
    required String year,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final uid = credential.user!.uid;
        final newUser = UserModel(
          uid: uid,
          name: name,
          email: email,
          phone: '',
          college: college,
          department: department,
          year: year,
          profilePhoto: '',
          bio: '',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          verified: false,
          role: 'student',
        );

        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        await credential.user!.sendEmailVerification();
        state = AuthState(userModel: newUser);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message);
      return false;
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        // Update last login
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLogin': Timestamp.fromDate(DateTime.now()),
        });
        await _fetchUserProfile(credential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message);
      return false;
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
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
            name: userCredential.user!.displayName ?? 'New Student',
            email: userCredential.user!.email ?? '',
            phone: userCredential.user!.phoneNumber ?? '',
            college: 'SRM University', // Default value
            department: 'CS',
            year: 'Freshman',
            profilePhoto: userCredential.user!.photoURL ?? '',
            bio: '',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
            verified: true,
            role: 'student',
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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthNotifier(auth, firestore);
});
