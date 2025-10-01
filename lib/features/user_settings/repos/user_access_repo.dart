import 'package:gamdiwala/features/user_settings/models/user_access_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class UserAccessRepo {
  static Future<UserAccessDm> getUserAccess({required int userId}) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/User/userAccess',
        queryParams: {'userId': userId.toString()},
        token: token,
      );

      if (response == null) {
        return UserAccessDm(menuAccess: [], ledgerDate: []);
      }
      print(response);
      return UserAccessDm.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> setAppAccess({
    required int userId,
    required bool appAccess,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      'UserId': userId,
      'Access': appAccess,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/User/mobileAccess',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> setMenuAccess({
    required int userId,
    required int menuId,
    int? subMenuId,
    required bool menuAccess,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      'UserId': userId,
      'MENUID': menuId,
      'SUBMENUID': subMenuId,
      'Access': menuAccess,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/User/setAccess',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> setLedger({
    required int userId,
    String? ledgerStart,
    String? ledgerEnd,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      'UserId': userId,
      'LedgerStart': ledgerStart,
      'LedgerEnd': ledgerEnd,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/User/setLedger',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
