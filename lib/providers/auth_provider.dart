import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// AuthProvider exposes the signed-in user and auth actions to the whole
// widget tree via Provider, so screens don't call FirebaseAuth directly.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isResettingPassword = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isResettingPassword => _isResettingPassword;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signIn(email: email, password: password);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String ward = '',
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        ward: ward,
      );
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _setLoading(false);
      return false;
    }
  }

  // Called on app start if Firebase already has a signed-in user, so we
  // don't force them to log in again every time they open the app.
  Future<void> loadCurrentSession() async {
    final firebaseUser = _authService.currentFirebaseUser;
    if (firebaseUser == null) return;
    try {
      _currentUser = await _authService.fetchUserProfile(firebaseUser.uid);
      notifyListeners();
    } catch (_) {
      // Profile missing or unreadable - fall back to the login screen.
      _currentUser = null;
    }
  }

  // Sends a "reset your password" email through Firebase Auth. Returns
  // true on success so the UI can show a confirmation message; the actual
  // error (if any) is left in errorMessage for the caller to display.
  Future<bool> sendPasswordResetEmail(String email) async {
    _isResettingPassword = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
      _isResettingPassword = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isResettingPassword = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Refreshes the local user profile, e.g. after a premium upgrade.
  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    _currentUser = await _authService.fetchUserProfile(_currentUser!.id);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final message = e.toString().replaceAll('Exception: ', '');
    if (message.contains('user-not-found')) {
      return 'No account found with that email.';
    }
    if (message.contains('wrong-password')) {
      return 'Invalid email or password.';
    }
    if (message.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('weak-password')) {
      return 'Password should be at least 6 characters.';
    }
    if (message.contains('invalid-email')) {
      return 'Enter a valid email address.';
    }
    return message;
  }
}
