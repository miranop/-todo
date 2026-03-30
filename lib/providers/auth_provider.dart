import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/google_calendar_service.dart';

/// Provides the Google Calendar service singleton.
final googleCalendarServiceProvider = Provider<GoogleCalendarService>((ref) {
  return GoogleCalendarService();
});

/// Authentication state for Google account.
class AuthState {
  final GoogleSignInAccount? googleAccount;
  // Future: Microsoft account
  final bool isLoading;
  final String? error;

  const AuthState({
    this.googleAccount,
    this.isLoading = false,
    this.error,
  });

  bool get isGoogleSignedIn => googleAccount != null;
  bool get isSignedIn => isGoogleSignedIn;

  AuthState copyWith({
    GoogleSignInAccount? googleAccount,
    bool? isLoading,
    String? error,
    bool clearGoogle = false,
    bool clearError = false,
  }) {
    return AuthState(
      googleAccount: clearGoogle ? null : (googleAccount ?? this.googleAccount),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Manages authentication state for all calendar sources.
class AuthNotifier extends StateNotifier<AuthState> {
  final GoogleCalendarService _googleService;

  AuthNotifier(this._googleService) : super(const AuthState()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleService.signInSilently();
      state = state.copyWith(
        googleAccount: account,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await _googleService.signIn();
      if (account != null) {
        state = state.copyWith(googleAccount: account, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Google sign-in was cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in failed: $e',
      );
    }
  }

  Future<void> signOutGoogle() async {
    await _googleService.signOut();
    state = state.copyWith(clearGoogle: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final googleService = ref.watch(googleCalendarServiceProvider);
  return AuthNotifier(googleService);
});
