import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static const String userKey = 'user_data';
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> storeUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }

  Future<AuthResponse> login(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user != null) {
      await _ensureProfile(user);
    }
    return res;
  }

  Future<AuthResponse> register(String name, String email, String phone, String password) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone': phone,
      },
    );

    final user = res.user;
    if (user != null && res.session != null) {
      await _ensureProfile(
        user,
        overrideName: name,
        overridePhone: phone,
      );
    }

    return res;
  }

  Future<UserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    final user = session?.user;
    if (user == null) return await getStoredUser();

    // Ensure profile exists/complete before mapping
    await _ensureProfile(user);

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return await getStoredUser();

    final mapped = UserModel.fromProfile(user, profile);
    await storeUser(mapped);
    return mapped;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    await clearStoredData();
  }

  Future<UserModel?> updateProfile(Map<String, dynamic> updates) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final updated = await _client
        .from('profiles')
        .update(updates)
        .eq('id', user.id)
        .select()
        .single();

    final mapped = UserModel.fromProfile(user, updated);
    await storeUser(mapped);
    return mapped;
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> forgotPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> _ensureProfile(
    User user, {
    String? overrideName,
    String? overridePhone,
  }) async {
    final profile = await _client
        .from('profiles')
        .select('id, full_name, phone, role, address, city, country')
        .eq('id', user.id)
        .maybeSingle();

    final meta = user.userMetadata ?? {};
    final fullName = overrideName ?? meta['full_name']?.toString();
    final phone = overridePhone ?? meta['phone']?.toString();
    final role = meta['role']?.toString() ?? 'customer';

    if (profile == null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'phone': phone,
        'role': role,
      });
      return;
    }

    final Map<String, dynamic> updates = {};
    if ((profile['full_name'] == null || profile['full_name'].toString().isEmpty) &&
        fullName != null &&
        fullName.isNotEmpty) {
      updates['full_name'] = fullName;
    }
    if ((profile['phone'] == null || profile['phone'].toString().isEmpty) &&
        phone != null &&
        phone.isNotEmpty) {
      updates['phone'] = phone;
    }
    if (profile['role'] == null || profile['role'].toString().isEmpty) {
      updates['role'] = role;
    }

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', user.id);
    }
  }
}
