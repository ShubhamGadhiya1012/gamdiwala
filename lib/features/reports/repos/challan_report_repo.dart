import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class ChallanReportRepo {
  static Future<List<PartyDm>> getParties() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customer',
        token: token,
      );

      if (response == null || response['data'] == null) return [];

      return (response['data'] as List<dynamic>)
          .map((item) => PartyDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ItemDm>> getItems() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getitems',
        token: token,
      );

      if (response == null || response['data'] == null) return [];

      return (response['data'] as List<dynamic>)
          .map((item) => ItemDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> getChallanReport({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    // print(fromDate);
    // print(toDate);
    // print(pCode);
    // print(iCode);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/challanReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'ICode': iCode,
        },
        token: token,
      );
      print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
