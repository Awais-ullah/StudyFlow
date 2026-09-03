import 'package:equatable/equatable.dart';

/// All possible states the auth screens can be in.
/// Using a sealed-style class hierarchy means the UI can exhaustively
/// handle every case instead of guessing at booleans/flags.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String? message; // e.g. "Password reset email sent"
  const AuthSuccess({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}