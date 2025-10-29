import 'package:gamdiwala/features/user_settings/models/user_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class UsersRepo {
  static Future<List<UserDm>> getUsers() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/User/users',
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => UserDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
