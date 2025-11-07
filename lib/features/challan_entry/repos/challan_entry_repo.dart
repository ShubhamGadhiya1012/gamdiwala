import 'package:gamdiwala/features/challan_entry/models/order_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class ChallanRepo {
  static Future<List<ChallanOrderDm>> getOrders({
    required String date,
    required String status,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final response = await ApiService.getRequest(
      endpoint: '/Challan/getOrders',
      token: token,
      queryParams: {'Date': date, 'Status': status},
    );

    if (response == null || response['data'] == null) return [];

    return (response['data'] as List)
        .map((item) => ChallanOrderDm.fromJson(item))
        .toList();
  }

  static Future<dynamic> saveChallanEntry({
    required String invNos,
    required String date,
    required String pCode,
    required String vCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final body = {
      'Invno': invNos,
      'Date': date,
      'PCode': pCode,
      'VCode': vCode,
    };
    // print(body);
    try {
      final response = await ApiService.postRequest(
        endpoint: '/Challan/challanEntry',
        token: token,
        requestBody: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getChallanPdfData({
    required String challanNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Challan/generatePdf',
        token: token,
        queryParams: {'Invno': challanNo},
      );

      print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
