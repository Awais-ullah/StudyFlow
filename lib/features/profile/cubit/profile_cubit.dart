import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import '../../../models/user_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  StreamSubscription? _subscription;

  ProfileCubit(this._repository) : super(ProfileLoading());

  void loadProfile(String uid) {
    _subscription?.cancel();
    _subscription = _repository.watchProfile(uid).listen(
          (profile) {
        if (profile != null) {
          emit(ProfileLoaded(profile));
        } else {
          emit(const ProfileError('Profile not found.'));
        }
      },
      onError: (e) => emit(ProfileError('Failed to load profile: $e')),
    );
  }

  Future<void> updateProfile(UserProfile updated) async {
    // Optimistic update: show the new data immediately instead of waiting
    // for the Firestore write to complete and stream back to us. This is
    // what makes Save feel instant. If the write ends up failing, we
    // revert to whatever the last confirmed state was.
    final previousState = state;
    emit(ProfileLoaded(updated));

    try {
      await _repository.updateProfile(updated);
      // No need to emit again on success — watchProfile's stream will
      // also deliver this same data shortly, which is a harmless no-op
      // re-emit of identical data.
    } catch (e) {
      // Revert to the last known-good state and surface the error.
      if (previousState is ProfileLoaded) {
        emit(previousState);
      }
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}