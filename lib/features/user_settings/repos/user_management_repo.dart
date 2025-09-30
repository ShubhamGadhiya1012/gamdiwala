import 'package:gamdiwala/features/user_settings/models/engineer_dm.dart';
import 'package:gamdiwala/features/user_settings/models/salesman_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class UserManagementRepo {
  static Future<List<SalesmanDm>> getSalesmen() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/salesmen',
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => SalesmanDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<EngineerDm>> getEngineers() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/engineer',
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => EngineerDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> manageUser({
    required int userId,
    required String fullName,
    required String mobileNo,
    required String password,
    required int userType,
    required String pCodes,
    required String seCodes,
    required String eCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "userId": userId,
      "FullName": fullName,
      "mobileNo": mobileNo,
      "password": password,
      "userType": userType,
      "PCODEs": pCodes,
      "SECODEs": seCodes,
      "ECODEs": eCodes,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/User/manageUser',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
