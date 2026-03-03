import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  StreamSubscription<AuthState>? _authSubscription;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
      }
      _startAuthListener();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _startAuthListener() {
    _authSubscription?.cancel();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((authState) async {
      if (authState.session == null) {
        _user = null;
        _isAuthenticated = false;
        notifyListeners();
        return;
      }
      final current = await _authService.getCurrentUser();
      _user = current;
      _isAuthenticated = current != null;
      notifyListeners();
    });
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.login(email, password);
      _user = await _authService.getCurrentUser();
      _isAuthenticated = _user != null;
      _setLoading(false);
      return _isAuthenticated;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid email or password')) {
        _setError('This email is not registered. Please create an account.');
      } else {
        _setError(e.message);
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Register method
  Future<bool> register(String name, String email, String phone, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.register(name, email, phone, password);
      // If email confirmation is required, session may be null and profile upsert is skipped
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _setError('Check your email to confirm your account, then log in.');
        _isAuthenticated = false;
        _setLoading(false);
        return false;
      }

      _user = await _authService.getCurrentUser();
      _isAuthenticated = _user != null;
      _setLoading(false);
      return _isAuthenticated;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updated = await _authService.updateProfile(updates);
      if (updated != null) {
        _user = updated;
        _setLoading(false);
        return true;
      }
      _setError('Profile update failed');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Profile update failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.changePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Password change failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Password reset failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
