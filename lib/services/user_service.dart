import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<void> createUserProfile(String userId, String email) async {
    await supabase.from('users').insert({
      'id': userId,
      'email': email,
      'profile_completed': false,
    });
  }

  Future<bool> isProfileCompleted(String userId) async {
    final data = await supabase
        .from('users')
        .select('profile_completed')
        .eq('id', userId)
        .single();

    return data['profile_completed'] == true;
  }
}
