

import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class UserAuthorisationRepo {
  static Future<dynamic> authoriseUser({
    required int userId,
    required int userType,
    required String pCodes,
    required String seCodes,
    required String eCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "userId": userId,
      "userType": userType,
      "PCODEs": pCodes,
      "SECODEs": seCodes,
      'ECODEs': eCodes,
    };

    try {
      var response = await ApiService.postRequest(
        endpoint: '/Auth/Authorise',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
