import 'auth_profile_redirect_decision.dart';
class AuthProfileRedirectResult {
  const AuthProfileRedirectResult({
    required this.decision,
    this.message,
  });

  final AuthProfileRedirectDecision decision;
  final String? message;

  bool get isAuthenticated =>
      decision != AuthProfileRedirectDecision.unauthenticated;
}