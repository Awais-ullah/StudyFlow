import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_profile.dart';
import '../../../core/constants/firestore_paths.dart';

/// Handles all Firestore reads/writes for the user's profile document.
/// This is the ONLY place in the app that should know the exact
/// Firestore field names for a profile — everything else uses UserProfile.
class ProfileRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createInitialProfile(UserProfile profile) async {
    await _firestore.doc(FirestorePaths.userDoc(profile.uid)).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(uid, doc.data()!);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _firestore.doc(FirestorePaths.userDoc(profile.uid)).update(
      profile.toMap(),
    );
  }

  /// Real-time stream — used later so Dashboard/Profile screens update
  /// live if the profile changes anywhere (e.g. after editing).
  Stream<UserProfile?> watchProfile(String uid) {
    return _firestore.doc(FirestorePaths.userDoc(uid)).snapshots().map(
          (doc) => doc.exists ? UserProfile.fromMap(uid, doc.data()!) : null,
    );
  }
}