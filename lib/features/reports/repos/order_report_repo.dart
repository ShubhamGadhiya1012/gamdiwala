import 'package:gamdiwala/features/authentication/auth/models/party_dm.dart';
import 'package:gamdiwala/features/home/models/item_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class OrderReportRepo {
  static Future<List<PartyDm>> getParties() async {
    String? token = await SecureStorageHelper.read('token');
    final response = await ApiService.getRequest(
      endpoint: '/Master/customer',
      token: token,
    );
    if (response == null || response['data'] == null) return [];
    return (response['data'] as List<dynamic>)
        .map((e) => PartyDm.fromJson(e))
        .toList();
  }

  static Future<List<ItemDm>> getItems() async {
    String? token = await SecureStorageHelper.read('token');
    final response = await ApiService.getRequest(
      endpoint: '/Master/getitems',
      token: token,
    );
    if (response == null || response['data'] == null) return [];
    return (response['data'] as List<dynamic>)
        .map((e) => ItemDm.fromJson(e))
        .toList();
  }

  static Future<dynamic> getOrderReport({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String iCode,
    required String status,
    required String type,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    // print(status);
    // print(type);

    final response = await ApiService.getRequest(
      endpoint: '/Report/orderReport',
      queryParams: {
        'FromDate': fromDate,
        'ToDate': toDate,
        'PCode': pCode,
        'ICode': iCode,
        'Status': status,
        'Type': type,
      },
      token: token,
    );
    // print(response);
    return response;
  }
}
