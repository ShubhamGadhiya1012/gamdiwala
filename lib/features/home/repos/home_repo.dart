import 'package:gamdiwala/features/home/models/count_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class HomeRepo {
  static Future<dynamic> checkVersion({
    required String version,
    required String deviceId,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/version',
        token: token,
        queryParams: {'Version': version, 'DeviceID': deviceId},
      );

      if (response == null) {
        return [];
      }

      if (response is List) {
        return response;
      }

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        throw response['error'];
      }

      return [];
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<List<CountDm>> getCounts({required String seCode}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Dashboard/count',
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => CountDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
