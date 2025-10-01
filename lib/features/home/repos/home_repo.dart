import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class HomeRepo {
  static Future<List<ItemDm>> getItems({required String pCode}) async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Master/items',
      token: token,
      queryParams: {'PCODE': pCode},
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List)
        .map((item) => ItemDm.fromJson(item))
        .toList();
  }

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
}
