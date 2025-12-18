import 'package:gamdiwala/features/invoice_entry/models/invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/invoice_party_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class InvoiceEntryRepo {
  static Future<List<InvoicePartyDm>> getParties({
    required String fromDate,
    required String toDate,
    required String billPeriod,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    print(fromDate);
    print(toDate);
    print(billPeriod);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getParties',
        token: token,
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'BillPeriod': billPeriod,
        },
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => InvoicePartyDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<InvoiceChallanDm>> getChallans({
    required String fromDate,
    required String toDate,
    required String pCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    print(fromDate);
    print(toDate);
    print(pCode);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getChallans',
        token: token,
        queryParams: {'FromDate': fromDate, 'ToDate': toDate, 'PCode': pCode},
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => InvoiceChallanDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> saveInvoiceEntry({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String billPeriod,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Invoice/saveInvoice',
        token: token,
        requestBody: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'BillPeriod': billPeriod,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
