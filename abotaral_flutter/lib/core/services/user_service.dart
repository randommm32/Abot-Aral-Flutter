import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static Future<String?> getUserRole(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      
      return response['role'] as String?;
    } catch (e) {
      // If profile not found or error, return null (or handle as student default)
      return null;
    }
  }
}
