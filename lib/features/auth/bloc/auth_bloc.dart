import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignUpWithEmail>(_onSignUpWithEmail);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSignOut>(_onSignOut);
    on<AuthContinueAsGuest>(_onContinueAsGuest);
    on<AuthPasswordReset>(_onPasswordReset);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signInWithEmail(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(credential.user!));
    } on Exception catch (e) {
      emit(AuthError(_mapAuthError(e)));
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signUpWithEmail(
        event.email,
        event.password,
      );
      final user = credential.user!;

      await user.updateDisplayName(event.displayName);

      final userModel = UserModel.newUser(
        id: user.uid,
        email: event.email,
        displayName: event.displayName,
      );
      await _firestoreService.createUser(user.uid, userModel.toFirestore());

      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      emit(AuthError(_mapAuthError(e)));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        emit(AuthUnauthenticated());
        return;
      }
      final user = credential.user!;

      final doc = await _firestoreService.getUser(user.uid);
      if (!doc.exists) {
        final userModel = UserModel.newUser(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
        await _firestoreService.createUser(user.uid, userModel.toFirestore());
      }

      emit(AuthAuthenticated(user));
    } on Exception catch (e) {
      emit(AuthError(_mapAuthError(e)));
    }
  }

  Future<void> _onSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onContinueAsGuest(
    AuthContinueAsGuest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGuest());
  }

  Future<void> _onPasswordReset(
    AuthPasswordReset event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordReset(event.email);
      emit(AuthPasswordResetSent());
    } on Exception catch (e) {
      emit(AuthError(_mapAuthError(e)));
    }
  }

  String _mapAuthError(Exception e) {
    final message = e.toString();
    if (message.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (message.contains('wrong-password')) {
      return 'Incorrect password.';
    } else if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (message.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    } else if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return 'An error occurred. Please try again.';
  }
}
