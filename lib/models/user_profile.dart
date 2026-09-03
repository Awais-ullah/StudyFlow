import 'package:cloud_firestore/cloud_firestore.dart';

/// Plain data model for a user's profile document.
/// Models never talk to Firestore directly — they only know how to
/// convert to/from a Map, keeping Firestore-specific code isolated
/// to the repository layer.
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String university;
  final double studyGoalHours; // daily goal, e.g. 4.0
  final String? photoUrl;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.university = '',
    this.studyGoalHours = 4.0,
    this.photoUrl,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      university: map['university'] as String? ?? '',
      studyGoalHours: (map['studyGoalHours'] as num?)?.toDouble() ?? 4.0,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'university': university,
      'studyGoalHours': studyGoalHours,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? university,
    double? studyGoalHours,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      university: university ?? this.university,
      studyGoalHours: studyGoalHours ?? this.studyGoalHours,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}