import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isRegisterMode = false.obs;
  final Rxn<User> currentUser = Rxn<User>();

  bool get isAuthenticated => currentUser.value != null;

  String get userEmail => currentUser.value?.email ?? 'No email';
  String get userName => currentUser.value?.displayName ?? 'Guest User';
  String get userPhotoUrl => currentUser.value?.photoURL ?? '';
  bool get isGuestUser => currentUser.value?.isAnonymous ?? false;

  @override
  void onInit() {
    currentUser.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  Future<void> signInOrRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    try {
      isLoading.value = true;
      if (isRegisterMode.value) {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      _showSuccess(isRegisterMode.value ? 'Account created' : 'Signed in');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication error');
    } catch (_) {
      _showError('Something went wrong, try again');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continueAsGuest() async {
    try {
      isLoading.value = true;
      await _auth.signInAnonymously();
      _showSuccess('Continuing as guest');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Guest sign-in failed');
    } catch (_) {
      _showError('Unable to continue as guest');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _showSuccess('Signed in with Google');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google sign-in failed');
    } catch (e) {
      _showError('Google sign-in error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {
      _showError('Sign out failed');
    }
  }

  void toggleMode() {
    isRegisterMode.toggle();
  }

  void _showError(String message) {
    AppSnackbar.show(
      title: 'Authentication',
      message: message,
      isError: true,
    );
  }

  void _showSuccess(String message) {
    AppSnackbar.show(
      title: 'Authentication',
      message: message,
    );
  }

  Future<void> updateUserProfile(String displayName) async {
    try {
      await currentUser.value?.updateDisplayName(displayName);
      await currentUser.value?.reload();
      currentUser.value = _auth.currentUser;
      _showSuccess('Profile updated');
    } catch (_) {
      _showError('Failed to update profile');
    }
  }

  Future<void> linkAnonymousAccountToEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      isLoading.value = true;

      if (!isGuestUser) {
        _showError('Not a guest account');
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await currentUser.value?.linkWithCredential(credential);

      if (displayName != null && displayName.isNotEmpty) {
        await currentUser.value?.updateDisplayName(displayName);
      }

      // Reload user to refresh authentication state
      await currentUser.value?.reload();
      currentUser.value = _auth.currentUser;

      _showSuccess('Account linked successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('This email is already in use');
      } else if (e.code == 'invalid-email') {
        _showError('Invalid email address');
      } else if (e.code == 'weak-password') {
        _showError('Password is too weak');
      } else {
        _showError(e.message ?? 'Failed to link account');
      }
    } catch (e) {
      _showError('Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> linkAnonymousAccountToGoogle() async {
    try {
      isLoading.value = true;

      if (!isGuestUser) {
        _showError('Not a guest account');
        return;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await currentUser.value?.linkWithCredential(credential);

      // Reload user to refresh authentication state
      await currentUser.value?.reload();
      currentUser.value = _auth.currentUser;

      _showSuccess('Account linked with Google');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        _showError('This Google account is already linked to another user');
      } else {
        _showError(e.message ?? 'Failed to link with Google');
      }
    } catch (e) {
      _showError('Google link error');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
