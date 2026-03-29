import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../app/routes/admin_web_routes.dart';
import '../../../app/services/admin_web_bootstrap_service.dart';
import '../../../app/services/admin_web_session_service.dart';

class AdminAuthController extends GetxController {
  AdminAuthController({
    FirebaseAuth? auth,
    AdminWebSessionService? sessionService,
    AdminWebBootstrapService? bootstrapService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _sessionService = sessionService ?? Get.find<AdminWebSessionService>(),
        _bootstrapService =
            bootstrapService ?? Get.find<AdminWebBootstrapService>();

  final FirebaseAuth _auth;
  final AdminWebSessionService _sessionService;
  final AdminWebBootstrapService _bootstrapService;

  final RxBool isLoginLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (isLoginLoading.value) return;

    try {
      isLoginLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final bool needsSetup =
      await _bootstrapService.shouldShowSuperAdminSetup();

      if (needsSetup) {
        Get.offAllNamed(AdminWebRoutes.setupSuperAdmin);
        return;
      }

      final bool hasAccess = await _sessionService.hasCurrentUserAdminAccess();

      if (!hasAccess) {
        await _sessionService.signOut();

        MBNotification.warning(
          title: 'Access denied',
          message:
          'This account exists, but no admin permission has been assigned.',
        );
        return;
      }

      MBNotification.success(
        title: 'Login successful',
        message: 'Welcome to MuthoBazar Admin.',
      );

      Get.offAllNamed(AdminWebRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      MBNotification.error(
        title: 'Login failed',
        message: _firebaseErrorMessage(e),
      );
    } catch (_) {
      MBNotification.error(
        title: 'Login failed',
        message: 'Unable to sign in right now.',
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (isRegisterLoading.value) return;

    try {
      isRegisterLoading.value = true;

      final UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user != null && fullName.trim().isNotEmpty) {
        await user.updateDisplayName(fullName.trim());
        await user.reload();
      }

      // Normal auth registration only.
      // No super-admin bootstrap writes here.
      // No admin_permissions write here.

      final bool needsSetup =
      await _bootstrapService.shouldShowSuperAdminSetup();

      if (needsSetup) {
        MBNotification.info(
          title: 'Account created',
          message:
          'Account created successfully. Continue to first super admin setup.',
        );
        Get.offAllNamed(AdminWebRoutes.setupSuperAdmin);
        return;
      }

      await _sessionService.signOut();

      MBNotification.success(
        title: 'Registration successful',
        message:
        'Your account has been created. Admin access must be assigned separately.',
      );

      Get.offAllNamed(AdminWebRoutes.login);
    } on FirebaseAuthException catch (e) {
      MBNotification.error(
        title: 'Registration failed',
        message: _firebaseErrorMessage(e),
      );
    } catch (_) {
      MBNotification.error(
        title: 'Registration failed',
        message: 'Unable to create account right now.',
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}