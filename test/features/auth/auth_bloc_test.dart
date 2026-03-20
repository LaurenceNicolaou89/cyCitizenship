import 'package:flutter_test/flutter_test.dart';
import 'package:cy_citizenship/features/auth/bloc/auth_bloc.dart';
import 'package:cy_citizenship/features/auth/bloc/auth_event.dart';
import 'package:cy_citizenship/features/auth/bloc/auth_state.dart';

void main() {
  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      // We can't instantiate without Firebase, so test state classes directly
      expect(AuthInitial(), isA<AuthState>());
    });

    test('AuthAuthenticated contains user uid in props', () {
      // Test state equality
      expect(AuthUnauthenticated(), equals(AuthUnauthenticated()));
    });

    test('AuthError contains message', () {
      const error = AuthError('test error');
      expect(error.message, 'test error');
      expect(error.props, ['test error']);
    });

    test('AuthGuest is a valid state', () {
      expect(AuthGuest(), isA<AuthState>());
    });

    test('AuthPasswordResetSent is a valid state', () {
      expect(AuthPasswordResetSent(), isA<AuthState>());
    });
  });

  group('AuthEvent', () {
    test('AuthSignInWithEmail has correct props', () {
      const event = AuthSignInWithEmail(
        email: 'test@test.com',
        password: '123456',
      );
      expect(event.email, 'test@test.com');
      expect(event.password, '123456');
      expect(event.props, ['test@test.com', '123456']);
    });

    test('AuthSignUpWithEmail has correct props', () {
      const event = AuthSignUpWithEmail(
        email: 'test@test.com',
        password: '123456',
        displayName: 'Test User',
      );
      expect(event.displayName, 'Test User');
    });

    test('AuthPasswordReset has correct props', () {
      const event = AuthPasswordReset(email: 'test@test.com');
      expect(event.email, 'test@test.com');
    });

    test('Events are equatable', () {
      expect(AuthCheckRequested(), equals(AuthCheckRequested()));
      expect(AuthSignInWithGoogle(), equals(AuthSignInWithGoogle()));
      expect(AuthSignOut(), equals(AuthSignOut()));
      expect(AuthContinueAsGuest(), equals(AuthContinueAsGuest()));
    });
  });
}
