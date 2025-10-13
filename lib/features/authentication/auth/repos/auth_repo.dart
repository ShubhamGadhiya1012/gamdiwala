import 'package:gamdiwala/features/authentication/auth/models/company_dm.dart';
import 'package:gamdiwala/services/api_service.dart';

class AuthRepo {
  static Future<List<CompanyDm>> loginUser({
    required String mobileNo,
    required String password,
    required String fcmToken,
    required String deviceId,
  }) async {
    final Map<String, dynamic> requestBody = {
      'mobileNo': mobileNo,
      'password': password,
      'FCMToken': fcmToken,
      'DeviceID': deviceId,
    };
    // print(requestBody);
    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/login',
        requestBody: requestBody,
      );
      // print(response);
      if (response != null && response['company'] != null) {
        return (response['company'] as List<dynamic>)
            .map((companyJson) => CompanyDm.fromJson(companyJson))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> getToken({
    required String mobileNumber,
    required int cid,
    required int yearId,
  }) async {
    final Map<String, dynamic> requestBody = {
      'mobileno': mobileNumber,
      'cid': cid,
      'yearId': yearId,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/token',
        requestBody: requestBody,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> registerUser({
    required String firstName,
    required String lastName,
    required String mobileNo,
    required String password,
  }) async {
    final Map<String, dynamic> requestBody = {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNo': mobileNo,
      'password': password,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/register',
        requestBody: requestBody,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
