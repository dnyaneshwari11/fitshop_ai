import 'package:supabase_flutter/supabase_flutter.dart';

class AddressService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch all saved addresses of current user
  Future<List<Map<String, dynamic>>> fetchAddresses() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('addresses')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Add new address
  Future<void> addAddress({
    required String name,
    required String phone,
    required String houseNo,
    required String area,
    required String landmark,
    required String city,
    required String pincode,
    required String addressType,
    double? latitude,
    double? longitude,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await supabase.from('addresses').insert({
      'user_id': user.id,
      'name': name.trim(),
      'phone': phone.trim(),
      'house_no': houseNo.trim(),
      'area': area.trim(),
      'landmark': landmark.trim().isEmpty ? null : landmark.trim(),
      'city': city.trim(),
      'pincode': pincode.trim(),
      'address_type': addressType.trim(),
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  /// Update existing address
  Future<void> updateAddress({
    required String id,
    required String name,
    required String phone,
    required String houseNo,
    required String area,
    required String landmark,
    required String city,
    required String pincode,
    required String addressType,
    double? latitude,
    double? longitude,
  }) async {
    await supabase.from('addresses').update({
      'name': name.trim(),
      'phone': phone.trim(),
      'house_no': houseNo.trim(),
      'area': area.trim(),
      'landmark': landmark.trim().isEmpty ? null : landmark.trim(),
      'city': city.trim(),
      'pincode': pincode.trim(),
      'address_type': addressType.trim(),
      'latitude': latitude,
      'longitude': longitude,
    }).eq('id', id);
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    await supabase.from('addresses').delete().eq('id', id);
  }
}