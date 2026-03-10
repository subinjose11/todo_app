import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<String> getIdToken();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException(message: 'User not found');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException(message: 'Failed to create user');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw const AuthException(message: 'Failed to sign in with Google');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<String> getIdToken() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'No user logged in');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw const AuthException(message: 'Failed to get ID token');
    }
    return token;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return UserModel.fromFirebaseUser(user);
    });
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      default:
        return 'Authentication failed: $code';
    }
  }
}
