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
}
