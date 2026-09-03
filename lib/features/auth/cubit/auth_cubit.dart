import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/auth_service.dart';
import '../../profile/repository/profile_repository.dart';
import '../../../models/user_profile.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final ProfileRepository _profileRepository;

  AuthCubit(this._authService, this._profileRepository) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _authService.signIn(email: email, password: password);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e)));
    } catch (e) {
      emit(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> register({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signUp(email: email, password: password);
      final uid = credential.user!.uid;

      await _profileRepository.createInitialProfile(
        UserProfile(uid: uid, email: email, displayName: email.split('@').first),
      );

      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e)));
    } catch (e) {
      emit(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(email);
      emit(AuthInitial());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e)));
    } catch (e) {
      emit(AuthFailure('Could not send reset email. Please try again.'));
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    emit(AuthInitial());
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}