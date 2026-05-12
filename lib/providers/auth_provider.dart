import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  User? _user;
  bool _profileCompleted = false;
  bool _loading = false;
  String? _goal;
  String? _role; // ✅ ADDED ROLE VARIABLE

  // ================= GETTERS =================

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get profileCompleted => _profileCompleted;
  bool get isLoading => _loading;
  String? get goal => _goal;
  String? get role => _role; // ✅ ADDED ROLE GETTER

  // =====================================================
  // ✅ APP START SESSION LOAD (MOST IMPORTANT)
  // =====================================================
  Future<void> checkSession() async {
    _loading = true;
    notifyListeners();

    _user = supabase.auth.currentUser;

    if (_user == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      // ✅ NOW FETCHING 'role' ALONG WITH GOAL AND COMPLETION
      final data = await supabase
          .from('profiles')
          .select('goal, profile_completed, role')
          .eq('id', _user!.id)
          .single(); 

      _goal = data['goal'];
      _profileCompleted = data['profile_completed'] == true;
      _role = data['role'] ?? 'user'; // Fallback to user just in case

      debugPrint("✅ Goal Loaded: $_goal | Role: $_role");
    } catch (e) {
      debugPrint("❌ Session fetch error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  // ================= SIGN UP =================

  Future<bool> signUp(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _loading = false;
        notifyListeners();
        return false;
      }

      _user = response.user;

      await supabase.from('profiles').insert({
        'id': _user!.id,
        'email': email,
        'goal': null,
        'profile_completed': false,
        'role': 'user', // ✅ Automatically assign 'user' role on signup
      });

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Signup error: $e");
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ================= LOGIN =================

  Future<bool> login(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _loading = false;
        notifyListeners();
        return false;
      }

      _user = response.user;

      // ✅ THIS WILL NOW FETCH THE ROLE
      await checkSession();

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ================= COMPLETE PROFILE =================

  Future<void> completeProfile(String goal) async {
    if (_user == null) return;

    _loading = true;
    notifyListeners();

    await supabase
        .from('profiles')
        .update({
          'goal': goal,
          'profile_completed': true,
        })
        .eq('id', _user!.id);

    _goal = goal;
    _profileCompleted = true;

    _loading = false;
    notifyListeners();
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    await supabase.auth.signOut();

    _user = null;
    _goal = null;
    _role = null; // ✅ CLEAR ROLE ON LOGOUT
    _profileCompleted = false;

    notifyListeners();
  }

  // =====================================================
  // ✅ REFRESH PROFILE DATA (VERY IMPORTANT)
  // =====================================================
  Future<void> refreshProfile() async {
    if (_user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('profile_completed, goal, role')
          .eq('id', _user!.id)
          .maybeSingle();

      if (data != null) {
        _profileCompleted = data['profile_completed'] == true;
        _goal = data['goal'];
        _role = data['role'] ?? 'user';

        debugPrint("✅ Goal refreshed: $_goal | Role: $_role");
      }
    } catch (e) {
      debugPrint("Profile refresh error: $e");
    }

    notifyListeners();
  }
}