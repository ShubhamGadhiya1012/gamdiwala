import 'dart:typed_data';

import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_dm.dart';
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_detail_dm.dart';
import 'package:gamdiwala/services/api_service.dart';
import 'package:gamdiwala/utils/helpers/secure_storage_helper.dart';

class InvoiceRepo {
  static Future<List<SaleInvoiceDm>> getSales({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getSales',
        queryParams: {
          'PageNumber': pageNumber.toString(),
          'PageSize': pageSize.toString(),
          'SearchText': searchText,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => SaleInvoiceDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<SaleInvoiceDetailDm?> getSalesDetail({
    required String invNo,
    required String yearId,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Invoice/getSalesDetail',
        queryParams: {'Invno': invNo, 'YearId': yearId},
        token: token,
      );

      if (response == null) return null;

      return SaleInvoiceDetailDm.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Uint8List?> printInvoice({
    required String invNo,
    required String bookCode,
    required String yearId,
    required String coCode,
    required String branchCode,
    required String pageSize,
  }) async {
    try {
      final baseUrl = 'http://160.187.80.165:8081/';
      final url =
          '$baseUrl?InvoiceNo=$invNo&BookCode=$bookCode&YearId=$yearId&CoCode=$coCode&BranchCode=$branchCode&PageSize=$pageSize';

      // print('Print Invoice URL: $url');

      final response = await ApiService.getRequest(fullUrl: url);

      // print('Response type: ${response.runtimeType}');

      if (response is Uint8List) {
        // print('PDF received - Size: ${response.length} bytes');
        return response;
      } else {
        // print('Response is not Uint8List: $response');
        throw 'Failed to generate PDF. Please retry after sometime.';
      }
    } catch (e) {
      // print('Print invoice error: $e');
      rethrow;
    }
  }
}
